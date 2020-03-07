//
//  RootView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import BsuirApi

struct RootView: View {

    @State var state = AppState(requestManager: .bsuir())

    var body: some View {
        TabView {
            AllGroupsView(screen: state.allGroups)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Группы")
                }

            AllLecturersView(screen: state.allLecturers)
                .tabItem {
                    Image(systemName: "person.crop.rectangle")
                    Text("Препедаватели")
                }
        }.edgesIgnoringSafeArea(.top)
    }
}
