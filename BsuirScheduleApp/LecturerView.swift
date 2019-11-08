//
//  LecturerView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/29/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct LecturerView: View {

    @ObservedObject var state: LecturerState

    var body: some View {
        ScheduleView(schedule: state.days)
            .onAppear(perform: state.request)
            .navigationBarTitle(Text(state.name), displayMode: .inline)
    }
}
