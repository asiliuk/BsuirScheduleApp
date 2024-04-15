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

final class ExamsScheduleProvider {
    typealias Entry = ExamsScheduleEntry
    typealias Context = TimelineProviderContext

    init(onlyExams: Bool) {
        self.staticOnlyExams = onlyExams
    }

    private func snapshot(in context: Context, onlyExams: Bool) async -> Entry {
        func completeCheckingPreview(with entry: ExamsScheduleEntry) -> Entry {
            return context.isPreview ? .preview(onlyExams: onlyExams) : entry
        }

        Logger.examsProvider.info("getSnapshot started")

        guard premiumService.isCurrentlyPremium else {
            Logger.examsProvider.info("getSnapshot no premium")
            return completeCheckingPreview(with: .premiumLocked)
        }

        guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
            Logger.examsProvider.info("getSnapshot no pinned")
            return completeCheckingPreview(with: .noPinned)
        }

        guard let schedule = try? await fetchExams(for: pinnedSchedule, onlyExams: onlyExams) else {
            Logger.examsProvider.info("getSnapshot failed to fetch")
            return .preview(onlyExams: onlyExams)
        }

        guard let entry = Entry(schedule, at: now) else {
            Logger.examsProvider.info("getSnapshot failed to create entry")
            return completeCheckingPreview(with: .noScheduleForPinned(
                title: schedule.title,
                subgroup: preferredSubgroup(for: pinnedSchedule)
            ))
        }

        Logger.examsProvider.info("getSnapshot success")
        return entry
    }

    private func timeline(in context: Context, onlyExams: Bool) async -> Timeline<Entry> {
        @Sendable func completeCheckingPreview(with entry: Entry) -> Timeline<Entry> {
            return .init(entries: [context.isPreview ? .preview(onlyExams: onlyExams) : entry], policy: .never)
        }

        Logger.examsProvider.info("getTimeline started")

        guard premiumService.isCurrentlyPremium else {
            Logger.examsProvider.info("getTimeline no premium")
            return completeCheckingPreview(with: .premiumLocked)
        }

        guard let pinnedSchedule = pinnedScheduleService.currentSchedule() else {
            Logger.examsProvider.info("getTimeline no pinned")
            return completeCheckingPreview(with: .noPinned)
        }

        do {
            let response = try await fetchExams(for: pinnedSchedule, onlyExams: onlyExams)
            guard let timeline = Timeline(response, now: now, calendar: calendar) else {
                Logger.examsProvider.info("getTimeline empty timeline")
                return completeCheckingPreview(with: .noScheduleForPinned(
                    title: response.title,
                    subgroup: preferredSubgroup(for: pinnedSchedule)
                ))
            }

            Logger.examsProvider.info("getTimeline success, entries: \(timeline.entries.count)")
            return timeline
        } catch {
            Logger.examsProvider.info("getTimeline failed to fetch")
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

            return Timeline(entries: entries, policy: .after(refresh))
        }
    }

    private func fetchExams(for source: ScheduleSource, onlyExams: Bool) async throws -> MostRelevantExamsScheduleResponse {
        switch source {
        case .group(let name):
            let schedule = try await apiClient.groupSchedule(name, false)
            return MostRelevantExamsScheduleResponse(
                deeplink: .group(name: name, displayType: .exams),
                title: source.title,
                subgroup: preferredSubgroup(for: source),
                exams: schedule.examSchedules,
                calendar: calendar,
                onlyExams: onlyExams
            )
        case .lector(let employee):
            let schedule = try await apiClient.lecturerSchedule(employee.urlId, false)
            return MostRelevantExamsScheduleResponse(
                deeplink: .lector(id: schedule.employee.id, displayType: .exams),
                title: source.title,
                subgroup: preferredSubgroup(for: source),
                exams: schedule.examSchedules ?? [],
                calendar: calendar,
                onlyExams: onlyExams
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

    private var staticOnlyExams: Bool
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

// MARK: - TimelineProvider

extension ExamsScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ExamsScheduleEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ExamsScheduleEntry) -> Void) {
        requestSnapshot = Task.detached(priority: .userInitiated) {
            completion(await self.snapshot(in: context, onlyExams: self.staticOnlyExams))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExamsScheduleEntry>) -> Void) {
        requestTimeline = Task.detached(priority: .userInitiated) {
            completion(await self.timeline(in: context, onlyExams: self.staticOnlyExams))
        }
    }
}

// MARK: - Log

import OSLog

private extension Logger {
    static let examsProvider = bsuirSchedule(category: "Exams Provider")
}
