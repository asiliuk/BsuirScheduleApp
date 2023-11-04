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

    func placeholder(in context: Context) -> PinnedScheduleEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PinnedScheduleEntry) -> Void) {
        requestSnapshot = Task {
            func completeCheckingPreview(with entry: PinnedScheduleEntry) {
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

    func getTimeline(in context: Context, completion: @escaping (Timeline<PinnedScheduleEntry>) -> Void) {
        func completeCheckingPreview(with entry: PinnedScheduleEntry) {
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

    private func mostRelevantSchedule(for source: ScheduleSource) async throws -> MostRelevantPinnedScheduleResponse? {
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
