import WidgetKit
import BsuirCore
import BsuirUI
import ScheduleCore
import Foundation
import Deeplinking
import BsuirApi

extension PinnedScheduleEntry {
    init?(_ response: MostRelevantPinnedScheduleResponse, at date: Date) {
        guard let schedule = response.schedule else { return nil }

        // Filter pairs based on subgroup
        let pairs = schedule.pairs
            .filter { $0.base.isSuitable(forSubgroup: response.subgroup) }

        // Find and split array by pair that is now in progress
        guard let index = pairs.firstIndex(where: { $0.end > date }) else { return nil }
        let passedPairs = pairs[..<index]
        let upcomingPairs = pairs[index...]
        guard let firstUpcomingPair = upcomingPairs.first else { return nil }

        self.init(
            date: date,
            relevance: TimelineEntryRelevance(date: date, firstPairStart: firstUpcomingPair.start),
            config: PinnedScheduleWidgetConfiguration(
                deeplink: deeplinkRouter.url(for: response.deeplink),
                title: response.title,
                subgroup: response.subgroup,
                day: schedule.date,
                content: .pairs(
                    passed: passedPairs.map { PairViewModel(pair: $0, date: date) },
                    upcoming: upcomingPairs.map { PairViewModel(pair: $0, date: date) }
                )
            )
        )
    }
}

// MARK: - TimelineEntryRelevance

extension TimelineEntryRelevance {
    init?(date: Date, firstPairStart: Date) {
        let timeToFirstPair = firstPairStart.timeIntervalSince(date)
        let relevanceInterval: TimeInterval = 10 * 60

        guard timeToFirstPair > 0, timeToFirstPair < relevanceInterval else { return nil }
        
        // Score should increase and be maximum when Pair starts
        // relevance interval is 10min so it is going to be
        // 1 -> 10 min before
        // 2 -> 5 min before
        // 3 -> when Pair starts
        let score = ((relevanceInterval - timeToFirstPair) / 5 * 60) + 1
        self.init(score: Float(score), duration: timeToFirstPair)
    }
}

// MARK: - Timeline

extension Timeline where EntryType == PinnedScheduleEntry {
    init?(_ response: MostRelevantPinnedScheduleResponse) {
        guard let schedule = response.schedule else { return nil }

        // Generate snapshot for every 10 minutes interval in-between pairs start & end dates
        // This will allow widget to show proper progress with 10 minutes precision
        var dates = schedule.pairs.flatMap { pair in
            stride(
                from: pair.start.timeIntervalSince1970,
                through: pair.end.timeIntervalSince1970,
                by: 10 * 60
            ).map { Date(timeIntervalSince1970: $0) }
        }

        // Generate initial snapshot for now as well
        // otherwise it could stuck in placeholder state until pairs start
        dates.prepend(.now)

        // Show no schedule for today widget for some time after pairs end
        if let dayScheduleEnd = schedule.pairs.last?.end {
            dates.append(dayScheduleEnd.advanced(by: 20 * 60))
        }

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
            start: pair.start,
            end: pair.end,
            pair: pair.base,
            progress: .constant(at: date, start: pair.start, end: pair.end)
        )
    }
}
