//
//  RootView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI


enum CurrentTab {
    case groups
    case lecturers
    case about
    case favorites
}

enum Overlay: Identifiable {
    var id: Self { self }
    case about
}

struct RootView: View {
    @StateObject private var state = AppState.bsuir()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentTab: CurrentTab? = .groups
    @State private var currentOverlay: Overlay? = nil

    @ViewBuilder var body: some View {
        switch horizontalSizeClass {
        case nil, .compact?:
            TabView(selection: $currentTab) {
                if !state.allFavorites.isEmpty { NavigationView { allFavorites }.tab(.favorites) }
                NavigationView { allGroups }.tab(.groups)
                NavigationView { allLecturers }.tab(.lecturers)
                NavigationView { about }.tab(.about)
            }
        case .regular?:
            NavigationView {
                sidebar

                switch currentTab {
                case nil, .groups:
                    allGroups
                case .lecturers:
                    allLecturers
                case .about:
                    about
                case .favorites:
                    allFavorites
                }

                SchedulePlaceholder()
            }
            .sheet(item: $currentOverlay) {
                switch $0 {
                case .about:
                    NavigationView { about }
                }
            }
        }
    }

    private var allGroups: some View {
        AllGroupsView(screen: state.allGroups)
    }

    private var allLecturers: some View {
        AllLecturersView(screen: state.allLecturers)
    }

    private var allFavorites: some View {
        AllFavoritesView(screen: state.allFavorites)
    }

    private var about: some View {
        AboutView()
    }

    private var sidebar: some View {
        List {
            NavigationLink(destination: allGroups, tag: .groups, selection: $currentTab) {
                CurrentTab.groups.label
            }

            NavigationLink(destination: allLecturers, tag: .lecturers, selection: $currentTab) {
                CurrentTab.lecturers.label
            }

            Button(action: { currentOverlay = .about }) {
                CurrentTab.about.label
            }


            if !state.allFavorites.isEmpty {
                DisclosureGroup(
                    content: {
                        ForEach(state.allFavorites.groups) {
                            Text($0.name)
                        }

                        ForEach(state.allFavorites.lecturers) {
                            Text($0.fullName)
                        }
                    },
                    label: {
                        NavigationLink(destination: allFavorites, tag: .favorites, selection: $currentTab) {
                            CurrentTab.favorites.label
                        }
                    }
                )
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Расписание")
    }
}

struct SchedulePlaceholder: View {
    var body: some View {
        Text("Please select schedule to view...")
    }
}

private extension View {
    func tab(_ tab: CurrentTab?) -> some View {
        self
            .tabItem { tab?.label }
            .tag(tab)
    }
}
private extension CurrentTab {
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
