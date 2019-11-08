//
//  AllGroupsView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import Foundation

struct AllGroupsView: View {

    @ObservedObject var state: AllGroupsState

    var body: some View {
        NavigationView {
            ContentStateView(content: state.groups) { value in
                List(value) { group in
                    NavigationLink(destination: GroupView(state: self.state.state(for: group))) {
                        Text(group.name)
                    }
                }
            }
            .navigationBarTitle("Все группы")
            .onAppear(perform: state.request)
        }
    }
}
