import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirCore
import ScheduleCore
import Deeplinking
import Favorites
import Combine
import Dependencies

final class PinnedScheduleProvider: TimelineProvider {
    typealias Entry = PinnedScheduleEntry

    func placeholder(in context: Context) -> Entry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        requestSnapshot = Task.detached(priority: .userInitiated) { [unowned self] in
            func completeCheckingPreview(with entry: PinnedScheduleEntry) {
                completion(context.isPreview ? .preview : entry)
            }

            Logger.pinnedProvider.info("getSnapshot started")

            guard premiumService.isCurrentlyPremium else {
                Logger.pinnedProvider.info("getSnapshot no premium")
                return completeCheckingPreview(with: .premiumLocked)
            }

            guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
                Logger.pinnedProvider.info("getSnapshot no pinned")
                return completeCheckingPreview(with: .noPinned)
            }

            guard let schedule = try? await mostRelevantSchedule(for: pinnedSchedule) else {
                Logger.pinnedProvider.info("getSnapshot failed to fetch")
                return completion(.preview)
            }

            guard let entry = Entry(schedule, at: Date()) else {
                Logger.pinnedProvider.info("getSnapshot failed to create entry")
                return completion(.noScheduleForPinned(
                    title: schedule.title,
                    subgroup: preferredSubgroup(for: pinnedSchedule)
                ))
            }

            Logger.pinnedProvider.info("getSnapshot success")
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        @Sendable func completeCheckingPreview(with entry: Entry) {
            completion(.init(entries: [context.isPreview ? .preview : entry], policy: .never))
        }

        Logger.pinnedProvider.info("getTimeline started")

        guard premiumService.isCurrentlyPremium else {
            Logger.pinnedProvider.info("getTimeline no premium")
            return completeCheckingPreview(with: .premiumLocked)
        }

        guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
            Logger.pinnedProvider.info("getTimeline no pinned")
            return completeCheckingPreview(with: .noPinned)
        }

        requestTimeline = Task.detached(priority: .userInitiated) { [unowned self] in
            do {
                let schedule = try await mostRelevantSchedule(for: pinnedSchedule)
                guard let timeline = Timeline(schedule) else {
                    Logger.pinnedProvider.info("getTimeline empty timeline")
                    return completeCheckingPreview(with: .noScheduleForPinned(
                        title: schedule.title,
                        subgroup: preferredSubgroup(for: pinnedSchedule)
                    ))
                }
                Logger.pinnedProvider.info("getTimeline success, entries: \(timeline.entries.count)")
                return completion(timeline)
            } catch {
                Logger.pinnedProvider.info("getTimeline failed to fetch")
                let refresh = Date().advanced(by: 5 * 60)
                let entries: [Entry] = {
                    switch RequestError(error) {
                    case .notConnectedToInternet:
                        return []
                    case .noSchedule:
                        return [.noScheduleForPinned(
                            title: pinnedSchedule.title,
                            subgroup: preferredSubgroup(for: pinnedSchedule)
                        )]
                    case .failedToDecode, .somethingWrongWithBsuir, .unknown:
                        return [.pinnedFailed(
                            title: pinnedSchedule.title,
                            subgroup: preferredSubgroup(for: pinnedSchedule),
                            refresh: refresh
                        )]
                    }
                }()

                completion(Timeline(entries: entries, policy: .after(refresh)))
            }
        }
    }

    private func mostRelevantSchedule(for source: ScheduleSource) async throws -> MostRelevantPinnedScheduleResponse {
        switch source {
        case let .group(name):
            let schedule = try await apiClient.groupSchedule(name, false)
            return MostRelevantPinnedScheduleResponse(
                deeplink: .group(name: schedule.studentGroup.name),
                title: source.title,
                subgroup: preferredSubgroup(for: source),
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.actualSchedule
            )
        case let .lector(lector):
            let schedule = try await apiClient.lecturerSchedule(lector.urlId, false)
            return MostRelevantPinnedScheduleResponse(
                deeplink: .lector(id: schedule.employee.id),
                title: source.title,
                subgroup: preferredSubgroup(for: source),
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.actualSchedule
            )
        }
    }

    private func preferredSubgroup(for source: ScheduleSource) -> Int? {
        subgroupFilterService.preferredSubgroup(source).value
    }

    deinit {
        requestSnapshot?.cancel()
        requestTimeline?.cancel()
    }

    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.pinnedScheduleService) private var pinnedScheduleService
    @Dependency(\.premiumService) private var premiumService
    @Dependency(\.subgroupFilterService) private var subgroupFilterService
    @Dependency(\.calendar) private var calendar

    private var requestSnapshot: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private var requestTimeline: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
}

import OSLog

private extension Logger {
    static let pinnedProvider = bsuirSchedule(category: "Pinned Provider")
}
