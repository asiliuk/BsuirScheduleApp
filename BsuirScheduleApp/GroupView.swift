//
//  GroupView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct GroupView: View {

    @ObservedObject var state: GroupState

    var body: some View {
        ScheduleView(schedule: state.days)
            .onAppear(perform: state.request)
            .navigationBarTitle(Text(state.name), displayMode: .inline)
    }
}

struct ScheduleView: View {

    let schedule: ContentState<[Day]>

    var body: some View {
        ContentStateView(content: schedule) { value in
            List {
                ForEach(value, id: \.title) { day in
                    Section(header: Text(day.title)) {
                        ForEach(day.pairs, id: \.self) { PairCell(pair: $0) }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
    }
}
