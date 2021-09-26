//
//  RootView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

enum CurrentSelection: Hashable {
    case groups
    case lecturers
    case favorites(selection: AllFavoritesView.Selection? = nil)
    case about
}

enum CurrentOverlay: Identifiable {
    var id: Self { self }
    case about
    case whatsNew
}

struct RootView: View {
    @ObservedObject var state: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentSelection: CurrentSelection?
    @State private var currentOverlay: CurrentOverlay?

    init(state: AppState) {
        _state = ObservedObject(initialValue: state)
        _currentSelection = State(initialValue: state.allFavorites.initialSelection)
        _currentOverlay = State(initialValue: state.whatsNew.items.isEmpty ? nil : .whatsNew)
    }

    var body: some View {
        content
            .onOpenURL { url in
                guard
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                    components.host == "bsuirschedule.app"
                else { return }

                switch components.path {
                case "/groups":
                    currentSelection = .groups
                case "/lecturers":
                    currentSelection = .lecturers
                default:
                    assertionFailure("Unexpected incoming URL \(url)")
                }
            }
            .sheet(item: $currentOverlay) { overlay in
                switch overlay {
                case .about:
                    NavigationView { AboutView(screen: state.about) }
                case .whatsNew:
                    WhatsNewView(
                        items: state.whatsNew.items,
                        onAppear: state.whatsNew.didShow
                    )
                }
            }
    }

    @ViewBuilder private var content: some View {
        switch horizontalSizeClass {
        case nil, .compact?:
            TabRootView(state: state, currentSelection: $currentSelection)
        case .regular?:
            SidebarRootView(state: state, currentSelection: $currentSelection, currentOverlay: $currentOverlay)
        case .some:
            EmptyView().onAppear { assertionFailure("Unexpected horizontalSizeClass") }
        }
    }
}

private extension AllFavoritesScreen {
    var initialSelection: CurrentSelection {
        if let group = groups.first {
            return .favorites(selection: .group(id: group.id))
        } else if let lecturer = lecturers.first {
            return .favorites(selection: .lecturer(id: lecturer.id))
        } else {
            return .groups
        }
    }
}

extension CurrentSelection {
    @ViewBuilder var label: some View {
        switch self {
        case .groups:
            Label("Группы", systemImage: "person.2")
        case .lecturers:
            Label("Преподаватели", systemImage: "person.text.rectangle")
        case .about:
            Label("О приложении", systemImage: "info.circle")
        case .favorites:
            Label("Избранные", systemImage: "star")
        }
    }
}
