import WidgetKit
import BsuirCore
import BsuirUI
import ScheduleCore
import Foundation
import Deeplinking
import BsuirApi

extension ExamsScheduleEntry {
    init?(
        _ response: MostRelevantExamsScheduleResponse,
        at date: Date
    ) {
        self.init(
            relevantPairs: response.relevantPairs(at: date),
            at: date,
            title: response.title,
            subgroup: response.subgroup,
            deeplink: response.deeplink
        )
    }

    init?(
        relevantPairs: [MostRelevantExamsScheduleResponse.ExamPair],
        at date: Date,
        title: String,
        subgroup: Int?,
        deeplink: Deeplink
    ) {
        guard let firstPair = relevantPairs.first else { return nil }

        let days = Dictionary(grouping: relevantPairs, by: \.date)
            .sorted(by: { $0.key < $1.key })
            .map { date, pairs in
                ExamsScheduleWidgetConfiguration.ExamDay(
                    date: date,
                    pairs: pairs.map {
                        PairViewModel(
                            start: $0.start,
                            end: $0.end,
                            pair: $0.pair
                        )
                    }
                )
            }

        self.init(
            date: date,
            relevance: TimelineEntryRelevance(date: date, firstPairStart: firstPair.start),
            config: ExamsScheduleWidgetConfiguration(
                deeplink: deeplinkRouter.url(for: deeplink),
                title: title,
                subgroup: subgroup,
                content: .exams(days: days)
            )
        )
    }
}

// MARK: - Timeline

extension Timeline where EntryType == ExamsScheduleEntry {
    init?(_ response: MostRelevantExamsScheduleResponse, now: Date, calendar: Calendar) {
        let relevantPairs = response.relevantPairs(at: now)

        guard let relevantDate = relevantPairs.first?.date else {
            // All exams have passed now
            return nil
        }

        // Generate entries only for first two pairs of same day to reduce load on widget kit
        let timelinePairs = relevantPairs
            .prefix(while: { calendar.isDate($0.date, inSameDayAs: relevantDate) })
            .prefix(2)

        // Generate snapshot for every 15 minutes interval in-between exams start & end dates
        // This will allow widget to show proper progress with 10 minutes precision
        var dates = timelinePairs.flatMap { pair in
            stride(
                from: pair.start.timeIntervalSince1970,
                through: pair.end.timeIntervalSince1970,
                by: 15 * 60
            ).map { Date(timeIntervalSince1970: $0) }
        }

        // Generate initial snapshot for now as well
        // otherwise it could stuck in placeholder state until pairs start
        dates.prepend(now)

        self.init(
            entries: dates.compactMap { date in
                ExamsScheduleEntry(
                    relevantPairs: relevantPairs,
                    at: date,
                    title: response.title,
                    subgroup: response.subgroup,
                    deeplink: response.deeplink
                )
            },
            policy: .atEnd
        )
    }
}
