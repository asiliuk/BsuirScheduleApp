import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirCore
import ScheduleCore
import Deeplinking
import Favorites
import Combine

final class PinnedScheduleProvider: TimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> ScheduleEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        requestSnapshot = Task {
            guard !context.isPreview else {
                return completion(.preview)
            }

            guard let pinnedSchedule = favoritesService.currentPinnedSchedule else {
                return completion(.noPinned)
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
        guard !context.isPreview else {
            return completion(.init(entries: [.preview], policy: .never))
        }

        guard let pinnedSchedule = favoritesService.currentPinnedSchedule else {
            return completion(.init(entries: [.noPinned], policy: .never))
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
            let schedule = try await apiClient.groupSchedule(name: name)
            return MostRelevantScheduleResponse(
                deeplink: .group(name: schedule.studentGroup.name),
                title: schedule.studentGroup.name,
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.schedules
            )
        case let .lector(lector):
            let schedule = try await apiClient.lecturerSchedule(urlId: lector.urlId)
            return MostRelevantScheduleResponse(
                deeplink: .lector(id: schedule.employee.id),
                title: schedule.employee.compactFio,
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.schedules ?? DaySchedule()
            )
        }
    }

    deinit {
        requestSnapshot?.cancel()
        requestTimeline?.cancel()
    }

    private let apiClient = ApiClient.live
    private let favoritesService = FavoritesService.live

    private let calendar = Calendar.current
    private var requestSnapshot: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private var requestTimeline: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
}
