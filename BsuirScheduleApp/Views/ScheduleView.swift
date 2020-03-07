//
//  ScheduleView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct ScheduleView: View {

    @ObservedObject var screen: ScheduleScreen

    var body: some View {
        ContentStateView(content: screen.state) { value in
            List {
                ForEach(value, id: \.title) { day in
                    Section(header: Text(day.title)) {
                        ForEach(day.pairs, id: \.self) { PairCell(pair: $0) }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .onAppear(perform: screen.load)
        .navigationBarTitle(Text(screen.name), displayMode: .inline)
    }
}
