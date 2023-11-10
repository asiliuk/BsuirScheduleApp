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

            os_log(.info, log: .pinnedProvider, "getSnapshot started")

            guard premiumService.isCurrentlyPremium else {
                os_log(.info, log: .pinnedProvider, "getSnapshot no premium")
                return completeCheckingPreview(with: .premiumLocked)
            }

            guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
                os_log(.info, log: .pinnedProvider, "getSnapshot no pinned")
                return completeCheckingPreview(with: .noPinned)
            }

            guard let schedule = try? await mostRelevantSchedule(for: pinnedSchedule) else {
                os_log(.info, log: .pinnedProvider, "getSnapshot failed to fetch")
                return completion(.preview)
            }

            guard let entry = Entry(schedule, at: Date()) else {
                os_log(.info, log: .pinnedProvider, "getSnapshot failed to create entry")
                return completion(.noScheduleForPinned(title: schedule.title))
            }

            os_log(.info, log: .pinnedProvider, "getSnapshot success")
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        @Sendable func completeCheckingPreview(with entry: Entry) {
            completion(.init(entries: [context.isPreview ? .preview : entry], policy: .never))
        }

        os_log(.info, log: .pinnedProvider, "getTimeline started")

        guard premiumService.isCurrentlyPremium else {
            os_log(.info, log: .pinnedProvider, "getTimeline no premium")
            return completeCheckingPreview(with: .premiumLocked)
        }

        guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
            os_log(.info, log: .pinnedProvider, "getTimeline no pinned")
            return completeCheckingPreview(with: .noPinned)
        }

        requestTimeline = Task.detached(priority: .userInitiated) { [unowned self] in
            do {
                let schedule = try await mostRelevantSchedule(for: pinnedSchedule)
                guard let timeline = Timeline(schedule) else {
                    os_log(.info, log: .pinnedProvider, "getTimeline empty timeline")
                    return completeCheckingPreview(with: .noScheduleForPinned(title: schedule.title))
                }
                os_log(.info, log: .pinnedProvider, "getTimeline success, entries: \(timeline.entries.count)")
                return completion(timeline)
            } catch {
                os_log(.info, log: .pinnedProvider, "getTimeline failed to fetch")
                completion(.init(entries: [], policy: .after(Date().advanced(by: 5 * 60))))
            }
        }
    }

    private func mostRelevantSchedule(for source: ScheduleSource) async throws -> MostRelevantPinnedScheduleResponse {
        switch source {
        case let .group(name):
            let schedule = try await apiClient.groupSchedule(name, false)
            return MostRelevantPinnedScheduleResponse(
                deeplink: .group(name: schedule.studentGroup.name),
                title: schedule.studentGroup.name,
                subgroup: preferredSubgroup(for: source),
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.schedules
            )
        case let .lector(lector):
            let schedule = try await apiClient.lecturerSchedule(lector.urlId, false)
            return MostRelevantPinnedScheduleResponse(
                deeplink: .lector(id: schedule.employee.id),
                title: schedule.employee.compactFio,
                subgroup: preferredSubgroup(for: source),
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.schedules ?? DaySchedule()
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

private extension OSLog {
    static let pinnedProvider = bsuirSchedule(category: "Pinned Provider")
}
