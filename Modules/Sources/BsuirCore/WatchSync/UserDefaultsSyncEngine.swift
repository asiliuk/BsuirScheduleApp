import Foundation
import OSLog
import WatchConnectivity
import Combine
import os
#if os(watchOS)
import WatchKit
#endif

// MARK: - Dependency

extension UserDefaultsWatchSyncService where Self == UserDefaultsSyncEngine {
    public static func live(defaults: UserDefaults, keys: Set<String>) -> any UserDefaultsWatchSyncService {
        UserDefaultsSyncEngine(defaults: defaults, keys: keys)
    }
}

// MARK: - Engine

/// Syncs an allow-listed set of UserDefaults keys between an iPhone app and its watch app
/// using WatchConnectivity's application context.
///
/// How it works:
/// - `timestamps` holds the time of the last write for every key (persisted).
/// - `lastKnown` holds the last value the engine has seen or applied for every key
///   (rebuilt from UserDefaults at launch, `NSNull` means "no value").
/// - `UserDefaults.didChangeNotification` is only a trigger: on every notification the synced
///   keys are diffed against `lastKnown`. A key that differs is a local change, and gets stamped.
/// - Remote values update `lastKnown` BEFORE they are written, so our own writes (and no-op
///   writes) diff to nothing and don't echo back.
/// - `updateApplicationContext` replaces the whole context, so every push is a full snapshot
///   of all synced keys. Merging is per key, newest timestamp wins.
///
/// Threading: the notification is posted synchronously on the thread that writes a default,
/// including our own writes (the timestamps key, applied remote values). The pipeline hops to
/// the main queue first, so the handler never runs inside a write and can't re-enter `state`'s
/// non-reentrant lock.
public final class UserDefaultsSyncEngine: NSObject, WCSessionDelegate, @unchecked Sendable, UserDefaultsWatchSyncService {

    // MARK: Configuration

    private let defaults: UserDefaults
    private let keys: Set<String>

    private let contextKey = "UserDefaultsSyncEngine.blob"
    private let timestampsKey = "UserDefaultsSyncEngine.timestamps"

    private let log: Logger = .bsuirSchedule(category: "UserDefaultsWatchSync")

    // MARK: State

    private struct State {
        var timestamps: [String: Date] = [:]
        /// `NSNull()` represents a key that has no value.
        var lastKnown: [String: NSObject] = [:]
    }

    private let state = OSAllocatedUnfairLock(uncheckedState: State())
    private var defaultsObserver: AnyCancellable?

    private var session: WCSession { .default }

    #if os(watchOS)
    // Accessed on the main queue only.
    private var pendingTasks: [WKWatchConnectivityRefreshBackgroundTask] = []
    private var observations: [NSKeyValueObservation] = []
    #endif

    // MARK: Lifecycle

    public init(defaults: UserDefaults = .standard, keys: Set<String>) {
        self.defaults = defaults
        self.keys = keys
        super.init()
    }

    public func start() {
        log.info("Started")

        // Must happen before observing, so `lastKnown` is a valid baseline for the first diff.
        seedState()

        defaultsObserver = NotificationCenter.default
            // Fires for every change in UserDefaults, the diff finds out if our keys changed.
            // `object: nil`: don't rely on which UserDefaults instance posts it.
            .publisher(for: UserDefaults.didChangeNotification)
            // Never run the handler inside a write, see "Threading" above
            .receive(on: DispatchQueue.main)
            // Diff and stamp right away (not after the batch). Emits only real local changes.
            .compactMap { [weak self] _ in
                let changed = self?.recordLocalChanges() ?? []
                return changed.isEmpty ? nil : changed
            }
            // Batch pushes that happen within 300ms
            .collect(.byTime(DispatchQueue.main, .milliseconds(300)))
            .sink { [weak self] batches in
                let changed = Set(batches.flatMap { $0 })
                self?.log.info("Local values changed for: \(changed.sorted().joined(separator: ", "), privacy: .public)")
                self?.push()
            }

        guard WCSession.isSupported() else {
            log.error("WCSession is not supported")
            return
        }

        // delegate must be set before activating
        session.delegate = self
        session.activate()

        #if os(watchOS)
        observations = [
            session.observe(\.activationState) { [weak self] _, _ in
                DispatchQueue.main.async { self?.completePendingTasks() }
            },
            session.observe(\.hasContentPending) { [weak self] _, _ in
                DispatchQueue.main.async { self?.completePendingTasks() }
            },
        ]
        #endif
    }

    // MARK: Local changes

    /// Diffs all synced keys against `lastKnown` and stamps the ones that changed.
    /// Returns the keys that really changed locally.
    private func recordLocalChanges() -> [String] {
        let now = Date.now

        return state.withLockUnchecked { state in
            var changed: [String] = []

            for key in keys.sorted() {
                let current = currentValue(for: key)
                // Same as last known: unrelated key, a no-op write, or the echo of a value we applied
                guard state.lastKnown[key]?.isEqual(current) != true else { continue }

                state.lastKnown[key] = current
                state.timestamps[key] = now
                changed.append(key)
            }

            if !changed.isEmpty { persist(state.timestamps) }
            return changed
        }
    }

    // MARK: Push

    /// Sends the full snapshot of all synced keys.
    /// A diff would be wrong here: the context is a single slot that is replaced on every
    /// call, so a partial context would erase the keys that are not in it.
    private func push() {
        guard WCSession.isSupported(), session.activationState == .activated else {
            log.error("Failed to push. WCSession is not supported or in invalid state.")
            return
        }
        #if os(iOS)
        guard session.isPaired, session.isWatchAppInstalled else {
            log.error("Failed to push. Session is not paired.")
            return
        }
        #endif

        let entries: [String: WatchSyncChangeEntry] = state.withLockUnchecked { state in
            var entries: [String: WatchSyncChangeEntry] = [:]
            for key in keys {
                guard let time = state.timestamps[key] else { continue }
                guard let entry = WatchSyncChangeEntry(timestamp: time, value: defaults.object(forKey: key)) else {
                    log.error("Skipping \(key, privacy: .public): value can't be encoded")
                    continue
                }
                entries[key] = entry
            }
            return entries
        }

        guard !entries.isEmpty else { return }

        do {
            let envelope = WatchSyncChangeEnvelope(entries: entries)
            let data = try envelope.data
            try session.updateApplicationContext([contextKey: data])
            log.info("Pushed: \(entries.keys.sorted().joined(separator: ", "), privacy: .public)")
        } catch {
            // Not fatal: the next local change or activation pushes again.
            log.error("Failed to update context. \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: Remote changes -> merge

    private struct MergeResult {
        var adoptedKeys: [String] = []                   // remote was newer: we took its timestamp
        var writes: [(key: String, value: Any?)] = []    // subset of adopted whose value really differs
        var keptLocal: [String] = []                     // local was newer: the other side is behind
    }

    /// Merges a remote snapshot per key by timestamp.
    /// Returns `true` if a push is needed afterwards: either we adopted remote values
    /// (acknowledge them, so the sender's received context is not left stale), or our
    /// local data is fresher than what the other side has.
    @discardableResult
    private func merge(context: [String: Any], reason: String) -> Bool {
        guard let data = context[contextKey] as? Data else {
            log.info("Nothing to merge (\(reason, privacy: .public)): no remote state yet")
            return false
        }
        guard let envelope = WatchSyncChangeEnvelope(from: data) else {
            log.error("Failed to merge (\(reason, privacy: .public)): failed to parse context")
            return false
        }

        let result: MergeResult = state.withLockUnchecked { state in
            var result = MergeResult()

            for key in keys.sorted() {
                let localTime = state.timestamps[key] ?? .distantPast
                let remote = envelope.entries[key]
                let remoteTime = remote?.timestamp ?? .distantPast

                if let remote, remoteTime > localTime {
                    // Bookkeeping first: when the write below triggers a notification,
                    // `lastKnown` already matches and the diff finds nothing.
                    let value = (remote.value as? NSObject) ?? NSNull()
                    let valueChanged = state.lastKnown[key]?.isEqual(value) != true

                    state.timestamps[key] = remoteTime
                    state.lastKnown[key] = value

                    result.adoptedKeys.append(key)
                    if valueChanged { result.writes.append((key, remote.value)) }
                } else if localTime > remoteTime {
                    result.keptLocal.append(key)
                }
            }

            persist(state.timestamps)
            return result
        }

        // Write outside the lock
        for (key, value) in result.writes {
            if let value {
                defaults.set(value, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }

        log.info("""
            Merged (\(reason, privacy: .public)). \
            Adopted remote: [\(result.adoptedKeys.joined(separator: ", "), privacy: .public)]. \
            Kept local: [\(result.keptLocal.joined(separator: ", "), privacy: .public)]
            """)

        return !result.adoptedKeys.isEmpty || !result.keptLocal.isEmpty
    }

    // MARK: Helpers

    private func currentValue(for key: String) -> NSObject {
        (defaults.object(forKey: key) as? NSObject) ?? NSNull()
    }

    /// Safe to call under the lock: it posts a notification synchronously, but the handler
    /// hops to the main queue before it touches `state`.
    private func persist(_ timestamps: [String: Date]) {
        defaults.set(timestamps, forKey: timestampsKey)
    }

    private func seedState() {
        let stored = (defaults.dictionary(forKey: timestampsKey) as? [String: Date]) ?? [:]
        let now = Date.now

        state.withLockUnchecked { state in
            state.timestamps = stored
            for key in keys {
                let value = currentValue(for: key)
                state.lastKnown[key] = value
                // Values that existed before the engine was installed get "now"
                if !(value is NSNull), state.timestamps[key] == nil {
                    state.timestamps[key] = now
                }
            }
            persist(state.timestamps)
        }
    }

    // MARK: WCSessionDelegate

    public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else {
            return
        }

        // Pick up whatever arrived while the app wasn't running, then publish our state.
        merge(context: session.receivedApplicationContext, reason: "activation did complete")
        push()
        #if os(watchOS)
        DispatchQueue.main.async { self.completePendingTasks() }
        #endif
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if merge(context: applicationContext, reason: "did receive app context") {
            push()
        }
        #if os(watchOS)
        DispatchQueue.main.async { self.completePendingTasks() }
        #endif
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        // noop
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        // required for switching between multiple watches
        session.activate()
    }

    public func sessionWatchStateDidChange(_ session: WCSession) {
        push()
    }
    #endif

    // MARK: watchOS background tasks

    #if os(watchOS)
    /// Call from `WKApplicationDelegate.handle(_:)`.
    /// Every WatchConnectivity background task MUST be completed, or the app's
    /// background budget is used up and the system terminates it.
    public func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let wcTask = task as? WKWatchConnectivityRefreshBackgroundTask {
                pendingTasks.append(wcTask)
            } else {
                task.setTaskCompletedWithSnapshot(false)
            }
        }
        completePendingTasks()
    }

    private func completePendingTasks() {
        guard !pendingTasks.isEmpty else { return }
        if session.activationState != .activated || !session.hasContentPending {
            pendingTasks.forEach { $0.setTaskCompletedWithSnapshot(false) }
            pendingTasks.removeAll()
        }
    }
    #endif
}
