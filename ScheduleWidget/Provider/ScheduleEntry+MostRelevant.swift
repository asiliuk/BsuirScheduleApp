import WidgetKit
import BsuirCore
import BsuirUI
import ScheduleCore
import Foundation
import Deeplinking

extension ScheduleEntry {
    init?(_ response: MostRelevantScheduleResponse, at date: Date) {
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
            config: ScheduleWidgetConfiguration(
                deeplink: deeplinkRouter.url(for: response.deeplink),
                title: response.title,
                subgroup: response.subgroup,
                content: .pairs(
                    passed: passedPairs.map { PairViewModel(pair: $0, date: date) },
                    upcoming: upcomingPairs.map { PairViewModel(pair: $0, date: date) }
                )
            )
        )
    }
}

// MARK: - Timeline

extension Timeline where EntryType == ScheduleEntry {
    init(_ response: MostRelevantScheduleResponse) {
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

// MARK: - Helpers

private extension PairViewModel {
    init(pair: WeekSchedule.ScheduleElement.Pair, date: Date) {
        self.init(
            pair: pair,
            progress: PairProgress(at: date, pair: pair)
        )
    }
}

private extension PairProgress {
    convenience init(at date: Date, pair: WeekSchedule.ScheduleElement.Pair) {
        self.init(constant: Self.progress(at: date, from: pair.start, to: pair.end))
    }
}
