//
//  RootView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import AboutFeature

enum CurrentSelection: Hashable {
    case groups
    case lecturers
    case about
}

enum CurrentOverlay: Identifiable {
    var id: Self { self }
    case about
}

struct RootView: View {
    @ObservedObject var state: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentOverlay: CurrentOverlay?

    var body: some View {
        content
            .onOpenURL(perform: state.deeplinkHandler.handle(url:))
            .sheet(item: $currentOverlay) { overlay in
                switch overlay {
                case .about:
                    NavigationView { AboutView(store: state.aboutStore) }
                }
            }
    }

    @ViewBuilder private var content: some View {
        switch horizontalSizeClass {
        case nil, .compact?:
            CompactRootView(state: state, currentSelection: $state.currentSelection)
        case .regular?:
            RegularRootView(state: state, currentSelection: $state.currentSelection, currentOverlay: $currentOverlay)
        case .some:
            EmptyView().onAppear { assertionFailure("Unexpected horizontalSizeClass") }
        }
    }
}

extension CurrentSelection {
    @ViewBuilder var label: some View {
        switch self {
        case .groups:
            Label("view.tabBar.groups.title", systemImage: "person.2")
        case .lecturers:
            Label("view.tabBar.lecturers.title", systemImage: "person.text.rectangle")
        case .about:
            Label("view.tabBar.about.title", systemImage: "info.circle")
        }
    }
}
