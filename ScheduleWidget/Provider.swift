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
        let deeplink: Deeplink
        let title: String
        let schedule: WeekSchedule.ScheduleElement
    }

    private func mostRelevantSchedule(for identifier: ScheduleIdentifier) -> AnyPublisher<MostRelevantScheduleResponse, RequestsManager.RequestError> {
        requestSchedule(for: identifier)
            .compactMap { [calendar] response in
                let now = Date()

                guard
                    let startDate = response.startDate,
                    let endDate = response.endDate,
                    let mostRelevantElement = WeekSchedule(
                        schedule: response.schedule,
                        startDate: startDate,
                        endDate: endDate
                    )
                    .schedule(starting: now, now: now, calendar: calendar)
                    .first(where: { $0.hasUnfinishedPairs(calendar: calendar, now: now) })
                else { return nil }

                return MostRelevantScheduleResponse(
                    deeplink: response.deeplink,
                    title: response.title,
                    schedule: mostRelevantElement
                )
            }
            .eraseToAnyPublisher()
    }

    private struct ScheduleResponse {
        let deeplink: Deeplink
        let title: String
        let startDate: Date?
        let endDate: Date?
        let schedule: DaySchedule
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

    private func requestSchedule(for identifier: ScheduleIdentifier) -> AnyPublisher<ScheduleResponse, RequestsManager.RequestError> {
        switch identifier {
        case let .group(name):
            return requestManager
                .request(BsuirIISTargets.GroupSchedule(groupNumber: name))
                .map { ScheduleResponse(
                    deeplink: .groups(id: $0.studentGroup.id),
                    title: $0.studentGroup.name,
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    schedule: $0.schedules
                ) }
                .eraseToAnyPublisher()
        case let .lecturer(urlId):
            return requestManager
                .request(BsuirIISTargets.EmployeeSchedule(urlId: urlId))
                .map { ScheduleResponse(
                    deeplink: .lecturers(id: $0.employee.id),
                    title: $0.employee.abbreviatedName,
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    schedule: $0.schedules ?? DaySchedule()
                ) }
                .eraseToAnyPublisher()
        }
    }

    private let calendar = Calendar.current
    private var requestSnapshotCancellable: AnyCancellable?
    private var requestTimelineCancellable: AnyCancellable?
    private let requestManager = RequestsManager.iisBsuir()
}

private extension Employee {
    var abbreviatedName: String {
        let abbreviation = [firstName, middleName]
            .compactMap { $0?.first }
            .map { String($0).capitalized }
            .joined()
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
            deeplink: response.deeplink,
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
            pair: pair,
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
