//
//  RootView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI


enum CurrentTab: Hashable {
    case groups
    case lecturers
    case about
    case favorites(selection: AllFavoritesView.Selection? = nil)
}


struct RootView: View {
    @StateObject var state: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentTab: CurrentTab?
    @State private var showWhatsNew: Bool = false

    var body: some View {
        content
            .onAppear {
                if let group = state.allFavorites.groups.first {
                    currentTab = .favorites(selection: .group(id: group.id))
                } else if let lecturer = state.allFavorites.lecturers.first {
                    currentTab = .favorites(selection: .lecturer(id: lecturer.id))
                } else {
                    currentTab = .groups
                }

                if !state.whatsNew.items.isEmpty {
                    showWhatsNew = true
                }
            }
            .sheet(isPresented: $showWhatsNew) {
                WhatsNewView(
                    items: state.whatsNew.items,
                    onAppear: state.whatsNew.didShow
                )
            }
    }

    @ViewBuilder private var content: some View {
        switch horizontalSizeClass {
        case nil, .compact?:
            TabRootView(state: state, currentTab: $currentTab)
        case .regular?:
            SidebarRootView(state: state, currentTab: $currentTab)
        case .some:
            EmptyView().onAppear { assertionFailure("Unexpected horizontalSizeClass") }
        }
    }
}


extension CurrentTab {
    @ViewBuilder var label: some View {
        switch self {
        case .groups:
            Label("Группы", systemImage: "person.2")
        case .lecturers:
            Label("Преподаватели", systemImage: "person.crop.rectangle")
        case .about:
            Label("О приложении", systemImage: "info.circle")
        case .favorites:
            Label("Избранные", systemImage: "star")
        }
    }
}
