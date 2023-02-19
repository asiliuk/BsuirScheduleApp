import Foundation
import Deeplinking
import ScheduleCore
import BsuirApi

struct MostRelevantScheduleResponse {
    let deeplink: Deeplink
    let title: String
    let schedule: WeekSchedule.ScheduleElement
}

extension MostRelevantScheduleResponse {
    init?(
        deeplink: Deeplink,
        title: String,
        startDate: Date?,
        endDate: Date?,
        schedule: DaySchedule,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        guard
            let startDate = startDate,
            let endDate = endDate,
            let mostRelevantElement = WeekSchedule(
                schedule: schedule,
                startDate: startDate,
                endDate: endDate
            )
            .schedule(starting: now, now: now, calendar: calendar)
            .first(where: { $0.hasUnfinishedPairs(now: now) })
        else { return nil }

        self.init(
            deeplink: deeplink,
            title: title,
            schedule: mostRelevantElement
        )
    }
}
