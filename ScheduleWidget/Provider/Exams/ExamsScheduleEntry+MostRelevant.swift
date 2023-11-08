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
        let relevantPairs = response.exams.filter { $0.end > date }

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
                deeplink: deeplinkRouter.url(for: response.deeplink),
                title: response.title,
                subgroup: response.subgroup,
                content: .exams(days: days)
            )
        )
    }
}

// MARK: - Timeline

extension Timeline where EntryType == ExamsScheduleEntry {
    init?(_ response: MostRelevantExamsScheduleResponse, now: Date, calendar: Calendar) {
        guard let firstRelevantIndex = response.exams.firstIndex(where: { $0.end > now }) else {
            // All exams have passed now
            return nil
        }

        // Generate entries only for first day and then update daily
        let relevantDate = response.exams[firstRelevantIndex].date
        let relevantExams = response.exams[firstRelevantIndex...]
            .prefix(while: { calendar.isDate($0.date, inSameDayAs: relevantDate) })

        // Generate snapshot for every 10 minutes interval in-between exams start & end dates
        // This will allow widget to show proper progress with 10 minutes precision
        var dates = relevantExams.flatMap { pair in
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
            entries: dates.compactMap { ExamsScheduleEntry(response, at: $0) },
            policy: .atEnd
        )
    }
}
