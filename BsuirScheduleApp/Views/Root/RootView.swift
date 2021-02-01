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
    @ObservedObject var state: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentTab: CurrentTab?
    @State private var showWhatsNew: Bool

    init(state: AppState) {
        _state = ObservedObject(initialValue: state)
        _currentTab = State(initialValue: state.allFavorites.initialTab)
        _showWhatsNew = State(initialValue: !state.whatsNew.items.isEmpty)
    }

    var body: some View {
        content
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
            TabRootView(
                state: state,
                currentTab: .init(
                    get: { currentTab ?? .groups },
                    set: { currentTab = $0 }
                )
            )
        case .regular?:
            SidebarRootView(state: state, currentTab: $currentTab)
        case .some:
            EmptyView().onAppear { assertionFailure("Unexpected horizontalSizeClass") }
        }
    }
}

private extension AllFavoritesScreen {
    var initialTab: CurrentTab {
        if let group = groups.first {
            return .favorites(selection: .group(id: group.id))
        } else if let lecturer = lecturers.first {
            return .favorites(selection: .lecturer(id: lecturer.id))
        } else {
            return .groups
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
