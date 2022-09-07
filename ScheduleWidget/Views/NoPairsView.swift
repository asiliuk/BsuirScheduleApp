//
//  NoPairsView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 06/09/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI

struct NoPairsView: View {
    var body: some View {
        Text("widget.schedule.empty")
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
