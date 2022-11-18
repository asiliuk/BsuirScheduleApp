//
//  DayScheduleViewModel.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 06/08/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import Foundation
import BsuirApi
import BsuirCore

final class DayScheduleViewModel: ObservableObject {
    private(set) var days: [DayViewModel]
    
    init(schedule: DaySchedule, calendar: Calendar, now: Date) {
        self.days = DaySchedule.WeekDay.allCases
            .compactMap { weekDay in
                guard
                    let pairs = schedule[weekDay],
                    !pairs.isEmpty
                else {
                    return nil
                }
                
                return DayViewModel(
                    title: weekDay.localizedName(in: calendar).capitalized,
                    pairs: pairs.map {
                        PairViewModel(
                            start: calendar.date(bySetting: $0.startLessonTime, of: now),
                            end: calendar.date(bySetting: $0.endLessonTime, of: now),
                            pair: $0
                        )
                    }
                )
            }
    }
}
