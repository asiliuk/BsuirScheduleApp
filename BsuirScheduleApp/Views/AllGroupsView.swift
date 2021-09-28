//
//  AllGroupsView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import Foundation
import BsuirCore

struct AllGroupsView: View {
    @ObservedObject var screen: AllGroupsScreen

    var body: some View {
        ContentStateWithSearchView(
            content: screen.groups,
            searchQuery: $screen.searchQuery,
            searchPlaceholder: "Найти группу"
        ) { section in
            Section(header: Text(section.title)) {
                ForEach(section.groups) { group in
                    NavigationLinkButton {
                        screen.selectedGroup = group
                    } label: {
                        Text(group.name)
                    }
                }
            }
        }
        .navigation(item: $screen.selectedGroup) { group in
            ScheduleView(screen: screen.screen(for: group))
        }
        .navigationTitle("Все группы")
    }
}

struct NavigationLinkButton<Label: View>: View {
    let action: () -> Void
    let label: Label

    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button {
            action()
        } label: {
            NavigationLink(destination: EmptyView()) {
                label
            }
        }
        .accentColor(.primary)
    }
}
