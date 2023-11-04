import WidgetKit
import BsuirCore
import BsuirUI
import ScheduleCore
import Foundation
import Deeplinking

extension PinnedScheduleEntry {
    init?(_ response: MostRelevantPinnedScheduleResponse, at date: Date) {
        // Filter pairs based on subgroup
        let pairs: [WeekSchedule.ScheduleElement.Pair]
        if let subgroup = response.subgroup {
            pairs = response.schedule.pairs.filter { pair in
                pair.base.subgroup == 0 || pair.base.subgroup == subgroup
            }
        } else {
            pairs = response.schedule.pairs
        }

        // Find and split array by pair that is now in progress
        guard let index = pairs.firstIndex(where: { $0.end > date }) else { return nil }
        let passedPairs = pairs[..<index]
        let upcomingPairs = pairs[index...]
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
            config: PinnedScheduleWidgetConfiguration(
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

extension Timeline where EntryType == PinnedScheduleEntry {
    init(_ response: MostRelevantPinnedScheduleResponse) {
        // Generate snapshot for every 10 minutes interval in-between pairs start & end dates
        // This will allow widget to show proper progress with 10 minutes precision
        var dates = response.schedule.pairs.flatMap { pair in
            stride(
                from: pair.start.timeIntervalSince1970,
                through: pair.end.timeIntervalSince1970,
                by: 10 * 60
            ).map { Date(timeIntervalSince1970: $0) }
        }

        // Generate initial snapshot for now as well
        // otherwise it could stuck in placeholder state until pairs start
        dates.prepend(.now)

        self.init(
            entries: dates.compactMap { PinnedScheduleEntry(response, at: $0) },
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
