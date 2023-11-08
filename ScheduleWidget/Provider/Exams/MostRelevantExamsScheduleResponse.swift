import Foundation
import Deeplinking
import ScheduleCore
import BsuirApi
import BsuirUI

struct MostRelevantExamsScheduleResponse {
    struct ExamPair {
        let date: Date
        let start: Date
        let end: Date
        let pair: Pair
    }

    let deeplink: Deeplink
    let title: String
    let subgroup: Int?
    let exams: [ExamPair]
}

extension MostRelevantExamsScheduleResponse {
    init(
        deeplink: Deeplink,
        title: String,
        subgroup: Int?,
        exams: [Pair],
        calendar: Calendar
    ) {
        self.deeplink = deeplink
        self.title = title
        self.subgroup = subgroup
        self.exams = exams.compactMap { ExamPair(pair: $0, calendar: calendar) }
    }
}

extension MostRelevantExamsScheduleResponse {
    func relevantPairs(at date: Date) -> [ExamPair] {
        exams.lazy
            .filter { $0.pair.isSuitable(forSubgroup: subgroup) }
            .filter { $0.end > date }
    }
}

private extension MostRelevantExamsScheduleResponse.ExamPair {
    init?(pair: Pair, calendar: Calendar) {
        guard
            let date = pair.dateLesson,
            let start = calendar.date(bySetting: pair.startLessonTime, of: date),
            let end = calendar.date(bySetting: pair.endLessonTime, of: date)
        else { return nil }

        self.init(date: date, start: start, end: end, pair: pair)
    }
}
