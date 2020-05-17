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

    @ObservedObject var screen: AllGroupsScreen

    var body: some View {
        NavigationView {
            ContentStateWithSearchView(
                content: screen.groups,
                searchQuery: $screen.searchQuery,
                searchPlaceholder: "Найти группу"
            ) { group in
                NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: group))) {
                    Text(group.name)
                }
            }
            .navigationBarTitle("Все группы")
        }
    }
}
