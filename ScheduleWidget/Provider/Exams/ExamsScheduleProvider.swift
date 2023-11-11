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

final class ExamsScheduleProvider: TimelineProvider {
    typealias Entry = ExamsScheduleEntry

    func placeholder(in context: Context) -> Entry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        requestSnapshot = Task.detached(priority: .userInitiated) { [unowned self] in
            func completeCheckingPreview(with entry: ExamsScheduleEntry) {
                completion(context.isPreview ? .preview : entry)
            }

            os_log(.info, log: .examsProvider, "getSnapshot started")

            guard premiumService.isCurrentlyPremium else {
                os_log(.info, log: .examsProvider, "getSnapshot no premium")
                return completeCheckingPreview(with: .premiumLocked)
            }

            guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
                os_log(.info, log: .examsProvider, "getSnapshot no pinned")
                return completeCheckingPreview(with: .noPinned)
            }

            guard let schedule = try? await fetchExams(for: pinnedSchedule) else {
                os_log(.info, log: .examsProvider, "getSnapshot failed to fetch")
                return completion(.preview)
            }

            guard let entry = Entry(schedule, at: now) else {
                os_log(.info, log: .examsProvider, "getSnapshot failed to create entry")
                return completeCheckingPreview(with: .noScheduleForPinned(
                    title: schedule.title,
                    subgroup: preferredSubgroup(for: pinnedSchedule)
                ))
            }

            os_log(.info, log: .examsProvider, "getSnapshot success")
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExamsScheduleEntry>) -> Void) {
        @Sendable func completeCheckingPreview(with entry: Entry) {
            completion(.init(entries: [context.isPreview ? .preview : entry], policy: .never) )
        }

        os_log(.info, log: .examsProvider, "getTimeline started")

        guard premiumService.isCurrentlyPremium else {
            os_log(.info, log: .examsProvider, "getTimeline no premium")
            return completeCheckingPreview(with: .premiumLocked)
        }

        guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
            os_log(.info, log: .examsProvider, "getTimeline no pinned")
            return completeCheckingPreview(with: .noPinned)
        }

        requestTimeline = Task.detached(priority: .userInitiated) { [unowned self] in
            guard let response = try? await fetchExams(for: pinnedSchedule) else {
                os_log(.info, log: .examsProvider, "getTimeline failed to fetch")
                return completion(.init(entries: [], policy: .after(Date().advanced(by: 5 * 60))))
            }

            guard let timeline = Timeline(response, now: now, calendar: calendar) else {
                os_log(.info, log: .examsProvider, "getTimeline empty timeline")
                return completeCheckingPreview(with: .noScheduleForPinned(
                    title: response.title,
                    subgroup: preferredSubgroup(for: pinnedSchedule)
                ))
            }

            os_log(.info, log: .examsProvider, "getTimeline success, entries: \(timeline.entries.count)")
            completion(timeline)
        }
    }

    private func fetchExams(for source: ScheduleSource) async throws -> MostRelevantExamsScheduleResponse {
        switch source {
        case .group(let name):
            let schedule = try await apiClient.groupSchedule(name, false)
            return MostRelevantExamsScheduleResponse(
                deeplink: .group(name: name, displayType: .exams),
                title: schedule.studentGroup.name,
                subgroup: preferredSubgroup(for: source),
                exams: schedule.examSchedules,
                calendar: calendar
            )
        case .lector(let employee):
            let schedule = try await apiClient.lecturerSchedule(employee.urlId, false)
            return MostRelevantExamsScheduleResponse(
                deeplink: .lector(id: schedule.employee.id, displayType: .exams),
                title: schedule.employee.compactFio,
                subgroup: preferredSubgroup(for: source),
                exams: schedule.examSchedules ?? [],
                calendar: calendar
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
    @Dependency(\.date.now) private var now

    private var requestSnapshot: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private var requestTimeline: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
}

import OSLog

private extension OSLog {
    static let examsProvider = bsuirSchedule(category: "Exams Provider")
}
