//
//  DayViewModel.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 06/08/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import Foundation
import BsuirCore

struct DayViewModel: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String?
    var pairs: [PairViewModel]
    var isToday: Bool = false
    var isMostRelevant: Bool = false
}
