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
            VStack {
                SearchBar(text: $screen.searchQuery, placeholder: "Найти группу")

                ContentStateView(content: screen.state) { value in
                    List(value) { group in
                        NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: group))) {
                            Text(group.name)
                        }
                    }
                }
            }
            .navigationBarTitle("Все группы")
            .onAppear(perform: screen.load)
        }
    }
}
