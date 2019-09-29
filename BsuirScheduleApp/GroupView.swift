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
        Group {
            if state.days.isEmpty {
                Text("Загрузка...")
            } else {
                List {
                    ForEach(state.days, id: \.title) { day in
                        Section(header: Text(day.title)) {
                            ForEach(day.pairs, id: \.self) { Text($0) }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .onAppear(perform: state.request)
        .navigationBarTitle(Text(state.name), displayMode: .inline)
    }
}
