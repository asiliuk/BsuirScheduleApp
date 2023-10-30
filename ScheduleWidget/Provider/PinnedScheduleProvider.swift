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
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> ScheduleEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        requestSnapshot = Task {
            func completeCheckingPreview(with entry: ScheduleEntry) {
                completion(context.isPreview ? .preview : entry)
            }

            guard premiumService.isCurrentlyPremium else {
                return completeCheckingPreview(with: .premiumLocked)
            }

            guard let pinnedSchedule = favoritesService.currentPinnedSchedule else {
                return completeCheckingPreview(with: .noPinned)
            }

            guard
                let schedule = try? await mostRelevantSchedule(for: pinnedSchedule),
                let entry = Entry(schedule, at: Date())
            else {
                return completion(.preview)
            }

            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        func completeCheckingPreview(with entry: ScheduleEntry) {
            completion(.init(entries: [context.isPreview ? .preview : entry], policy: .never))
        }

        guard premiumService.isCurrentlyPremium else {
            return completeCheckingPreview(with: .premiumLocked)
        }

        guard let pinnedSchedule = favoritesService.currentPinnedSchedule else {
            return completeCheckingPreview(with: .noPinned)
        }

        requestTimeline = Task {
            guard let schedule = try? await mostRelevantSchedule(for: pinnedSchedule) else {
                return completion(.init(entries: [], policy: .after(Date().advanced(by: 5 * 60))))
            }

            completion(Timeline(schedule))
        }
    }

    private func mostRelevantSchedule(for source: ScheduleSource) async throws -> MostRelevantScheduleResponse? {
        switch source {
        case let .group(name):
            let schedule = try await apiClient.groupSchedule(name, false)
            return MostRelevantScheduleResponse(
                deeplink: .group(name: schedule.studentGroup.name),
                title: schedule.studentGroup.name,
                subgroup: preferredSubgroup(for: source),
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.schedules
            )
        case let .lector(lector):
            let schedule = try await apiClient.lecturerSchedule(lector.urlId, false)
            return MostRelevantScheduleResponse(
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
    @Dependency(\.favorites) private var favoritesService
    @Dependency(\.premiumService) private var premiumService
    @Dependency(\.subgroupFilterService) private var subgroupFilterService

    private let calendar = Calendar.current
    private var requestSnapshot: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private var requestTimeline: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
}
