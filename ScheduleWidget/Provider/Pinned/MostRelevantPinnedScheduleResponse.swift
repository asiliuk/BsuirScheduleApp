import Foundation
import Deeplinking
import ScheduleCore
import BsuirApi

struct MostRelevantPinnedScheduleResponse {
    let deeplink: Deeplink
    let title: String
    let subgroup: Int?
    let schedule: WeekSchedule.ScheduleElement?
}

extension MostRelevantPinnedScheduleResponse {
    init(
        deeplink: Deeplink,
        title: String,
        subgroup: Int?,
        startDate: Date?,
        endDate: Date?,
        schedule: DaySchedule?,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        self.init(
            deeplink: deeplink,
            title: title,
            subgroup: subgroup,
            schedule: {
                guard
                    let schedule,
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
                return mostRelevantElement
            }()
        )
    }
}
