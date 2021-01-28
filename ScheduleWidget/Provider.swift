import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirCore
import Combine

final class Provider: IntentTimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> Entry {
        return .placeholder
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        if context.isPreview {
            return completion(.preview)
        }

        guard let identifier = ScheduleIdentifier(configuration: configuration) else {
            return completion(.placeholder)
        }

        requestSnapshotCancellable = mostRelevantSchedule(for: identifier)
            .map { response in Entry(response, at: Date()) }
            .replaceNil(with: .placeholder)
            .replaceError(with: .placeholder)
            .sink(receiveValue: completion)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        if context.isPreview {
            return completion(.init(entries: [.preview], policy: .never))
        }

        guard let identifier = ScheduleIdentifier(configuration: configuration) else {
            return completion(.init(entries: [.needsConfiguration], policy: .never))
        }

        requestTimelineCancellable = mostRelevantSchedule(for: identifier)
            .map { Timeline<Entry>($0) }
            .replaceError(with: .init(entries: [], policy: .after(Date().advanced(by: 5 * 60))))
            .sink(receiveValue: completion)
    }

    fileprivate struct MostRelevantScheduleResponse {
        let title: String
        let schedule: WeekSchedule.ScheduleElement
    }

    private func mostRelevantSchedule(for identifier: ScheduleIdentifier) -> AnyPublisher<MostRelevantScheduleResponse, RequestsManager.RequestError> {
        requestSchedule(for: identifier)
            .compactMap { [calendar] response in
                let now = Date()

                guard let mostRelevantElement = WeekSchedule(schedule: response.schedules, calendar: calendar)
                        .schedule(starting: now, now: now)
                        .first(where: { $0.hasUnfinishedPairs(calendar: calendar, now: now) })
                else { return nil }

                return MostRelevantScheduleResponse(
                    title: response.title,
                    schedule: mostRelevantElement
                )
            }
            .eraseToAnyPublisher()
    }

    private struct ScheduleResponse {
        let title: String
        let schedules: [DaySchedule]
    }

    private enum ScheduleIdentifier {
        case group(id: Int)
        case lecturer(id: Int)

        init?(configuration: ConfigurationIntent) {
            func makeId(_ identifier: String?) -> Int? { identifier.flatMap(Int.init) }
            switch configuration.type {
            case .unknown, .group:
                guard let groupId = makeId(configuration.groupNumber?.identifier) else { return nil }
                self = .group(id: groupId)
            case .lecturer:
                guard let lecturerId = makeId(configuration.lecturer?.identifier) else { return nil }
                self = .lecturer(id: lecturerId)
            }
        }
    }

    private func requestSchedule(for identifier: ScheduleIdentifier) -> AnyPublisher<ScheduleResponse, RequestsManager.RequestError> {
        switch identifier {
        case let .group(groupId):
            return requestManager
                .request(BsuirTargets.Schedule(agent: .groupID(groupId)))
                .map { ScheduleResponse(title: $0.studentGroup.name, schedules: $0.schedules) }
                .eraseToAnyPublisher()
        case let .lecturer(lecturerId):
            return requestManager
                .request(BsuirTargets.EmployeeSchedule(id: lecturerId))
                .map { ScheduleResponse(title: $0.employee.abbreviatedName, schedules: $0.schedules ?? []) }
                .eraseToAnyPublisher()
        }
    }

    private let calendar = Calendar.current
    private var requestSnapshotCancellable: AnyCancellable?
    private var requestTimelineCancellable: AnyCancellable?
    private let requestManager = RequestsManager.bsuir()
}

private extension Employee {
    var abbreviatedName: String {
        let abbreviation = [firstName, middleName].compactMap { $0.first }.map { String($0).capitalized }.joined()
        return [lastName, abbreviation].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

private extension ScheduleEntry {
    init?(_ response: Provider.MostRelevantScheduleResponse, at date: Date) {
        guard let index = response.schedule.pairs.firstIndex(where: { $0.end > date }) else { return nil }
        let passedPairs = response.schedule.pairs[..<index]
        let upcomingPairs = response.schedule.pairs[index...]
        guard let firstUpcomingPair = upcomingPairs.first else { return nil }

        var relevance: TimelineEntryRelevance?
        let timeToFirstPair = firstUpcomingPair.start.timeIntervalSince(date)
        let relevanceInterval: TimeInterval = 10 * 60
        if timeToFirstPair > 0, timeToFirstPair < relevanceInterval {
            // Score should increase and be maximum when Pair starts
            // relevance interval is 10min so it is going to be
            // 1 -> 10 min before
            // 2 -> 5 min before
            // 3 -> when Pair starts
            let score = ((relevanceInterval - timeToFirstPair) / 5 * 60) + 1

            relevance = TimelineEntryRelevance(score: Float(score), duration: timeToFirstPair)
        }

        self.init(
            date: date,
            relevance: relevance,
            title: response.title,
            content: .pairs(
                passed: passedPairs.map { PairViewModel(pair: $0, date: date) },
                upcoming: upcomingPairs.map { PairViewModel(pair: $0, date: date) }
            )
        )
    }
}

private extension PairViewModel {
    init(pair: WeekSchedule.ScheduleElement.Pair, date: Date) {
        self.init(
            pair.base,
            showWeeks: false,
            progress: PairProgress(at: date, pair: pair)
        )
    }
}

private extension Timeline where EntryType == ScheduleEntry {
    init(_ response: Provider.MostRelevantScheduleResponse) {
        let dates = response.schedule.pairs.flatMap { pair in
            stride(
                from: pair.start.timeIntervalSince1970,
                through: pair.end.timeIntervalSince1970,
                by: 10 * 60
            ).map { Date(timeIntervalSince1970: $0) }
        }

        self.init(
            entries: dates.compactMap { ScheduleEntry(response, at: $0) },
            policy: .atEnd
        )
    }
}

private extension PairProgress {
    convenience init(at date: Date, pair: WeekSchedule.ScheduleElement.Pair) {
        self.init(constant: Self.progress(at: date, from: pair.start, to: pair.end))
    }
}
