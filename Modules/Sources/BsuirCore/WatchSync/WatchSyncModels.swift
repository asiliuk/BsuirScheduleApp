import Foundation

struct WatchSyncChangeEnvelope {
    /// Version of the model
    let version: Int
    /// Dictionary of changes keyed by value storage key
    let entries: [String: WatchSyncChangeEntry]

    init(entries: [String: WatchSyncChangeEntry]) {
        self.version = Self.currentVersion
        self.entries = entries
    }
}

struct WatchSyncChangeEntry {
    /// Timestamp of the change
    let timestamp: Date
    /// Value that changed. `nil` means deletion
    let value: Any?

    init?(timestamp: Date, value: Any?) {
        self.timestamp = timestamp
        self.value = value
        guard PropertyListSerialization.propertyList(plist, isValidFor: .binary) else { return nil }
    }
}

// MARK: - Coding

extension WatchSyncChangeEnvelope {
    var data: Data {
        get throws {
            try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
        }
    }

    init?(from data: Data) {
        guard
            let decoded = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let plist = decoded as? [String: Any],
            let envelope = WatchSyncChangeEnvelope(from: plist),
            envelope.version == Self.currentVersion
        else { return nil }
        self = envelope
    }
}


// MARK: - Plist

private extension WatchSyncChangeEntry {
    var plist: [String: Any] {
        var data: [String: Any] = [:]
        data[Self.timestampKey] = timestamp
        data[Self.valueKey] = value
        return data
    }

    init?(from plist: [String: Any]) {
        guard let timestamp = plist[Self.timestampKey] as? Date else { return nil }
        self.timestamp = timestamp
        self.value = plist[Self.valueKey]
    }

    static let timestampKey = "t"
    static let valueKey = "v"
}

private extension WatchSyncChangeEnvelope {
    var plist: [String: Any] {
        [
            Self.versionKey: version,
            Self.entriesKey: entries.mapValues(\.plist)
        ]
    }

    init?(from plist: [String: Any]) {
        guard
            let version = plist[Self.versionKey] as? Int,
            let entries = plist[Self.entriesKey] as? [String: [String: Any]]
        else { return nil }
        self.version = version
        self.entries = entries.compactMapValues { WatchSyncChangeEntry(from: $0) }
    }

    static let currentVersion = 1
    static let versionKey = "ver"
    static let entriesKey = "e"
}
