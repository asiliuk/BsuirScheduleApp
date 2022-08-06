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
    
    init(schedule: DaySchedule) {
        self.days = DaySchedule.WeekDay.allCases
            .compactMap { weekDay in
                guard
                    let pairs = schedule[weekDay],
                    !pairs.isEmpty
                else {
                    return nil
                }
                
                return DayViewModel(
                    title: weekDay.rawValue,
                    pairs: pairs.map { PairViewModel($0) }
                )
            }
    }
}
