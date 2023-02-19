import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirCore
import ScheduleCore
import Deeplinking
import Combine

final class Provider: IntentTimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> Entry {
        return .placeholder
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        requestSnapshot = Task {
            if context.isPreview {
                return completion(.preview)
            }

            guard
                let identifier = ScheduleIdentifier(configuration: configuration),
                let schedule = try? await mostRelevantSchedule(for: identifier),
                let entry = Entry(schedule, at: Date())
            else {
                return completion(.placeholder)
            }

            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        if context.isPreview {
            return completion(.init(entries: [.preview], policy: .never))
        }

        guard let identifier = ScheduleIdentifier(configuration: configuration) else {
            return completion(.init(entries: [.needsConfiguration], policy: .never))
        }

        requestTimeline = Task {
            guard let schedule = try? await mostRelevantSchedule(for: identifier) else {
                return completion(.init(entries: [], policy: .after(Date().advanced(by: 5 * 60))))
            }

            completion(Timeline(schedule))
        }
    }

    private func mostRelevantSchedule(for identifier: ScheduleIdentifier) async throws -> MostRelevantScheduleResponse? {
        switch identifier {
        case let .group(name):
            let schedule = try await apiClient.groupSchedule(name: name)
            return MostRelevantScheduleResponse(
                deeplink: .group(name: schedule.studentGroup.name),
                title: schedule.studentGroup.name,
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.schedules
            )
        case let .lecturer(urlId):
            let schedule = try await apiClient.lecturerSchedule(urlId: urlId)
            return MostRelevantScheduleResponse(
                deeplink: .lector(id: schedule.employee.id),
                title: schedule.employee.compactFio,
                startDate: schedule.startDate,
                endDate: schedule.endDate,
                schedule: schedule.schedules ?? DaySchedule()
            )
        }
    }

    private enum ScheduleIdentifier {
        case group(name: String)
        case lecturer(urlId: String)

        init?(configuration: ConfigurationIntent) {
            switch configuration.type {
            case .unknown, .group:
                guard let groupName = configuration.groupName?.identifier else { return nil }
                self = .group(name: groupName)
            case .lecturer:
                guard let lecturerUrlId = configuration.lecturerUrlId?.identifier else { return nil }
                self = .lecturer(urlId: lecturerUrlId)
            }
        }
    }

    deinit {
        requestSnapshot?.cancel()
        requestTimeline?.cancel()
    }

    private let calendar = Calendar.current
    private var requestSnapshot: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private var requestTimeline: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }
    private let apiClient = ApiClient.live
}
