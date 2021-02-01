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
    @Binding var selectedGroup: Int?

    var body: some View {
        ContentStateWithSearchView(
            content: screen.groups,
            searchQuery: $screen.searchQuery,
            searchPlaceholder: "Найти группу"
        ) { section in
            Section(header: Text(section.title)) {
                ForEach(section.groups, id: \.id) { group in
                    NavigationLinkButton {
                        selectedGroup = group.id
                    } label: {
                        Text(group.name)
                    }
                }
            }
        } backgroundView: { sections in
            ForEach(sections) { section in
                ForEach(section.groups, id: \.id) { group in
                    NavigationLink(
                        destination: ScheduleView(screen: screen.screen(for: group)),
                        tag: group.id,
                        selection: $selectedGroup
                    ) { EmptyView() }
                }
            }
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
