//
//  RootView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import BsuirApi

import os.log

enum CurrentTab: CaseIterable {
    case groups
    case lecturers
    case about
}

struct RootView: View {
    @StateObject private var state = AppState(
        requestManager: .bsuir(
            session: {
                var configuration = URLSessionConfiguration.default
                configuration.urlCache = .init(memoryCapacity: Int(1e7),
                                               diskCapacity: Int(1e7),
                                               diskPath: nil)
                configuration.requestCachePolicy = .returnCacheDataElseLoad
                return URLSession(configuration: configuration)
            }(),
            logger: .osLog
        )
    )
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentTab: CurrentTab? = .groups

    @ViewBuilder var body: some View {
        switch horizontalSizeClass {
        case nil, .compact?:
            TabView(selection: $currentTab) {
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
                }

                SchedulePlaceholder()
            }
        }
    }

    private var allGroups: some View {
        AllGroupsView(screen: state.allGroups)
    }

    private var allLecturers: some View {
        AllLecturersView(screen: state.allLecturers)
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

            NavigationLink(destination: about, tag: .about, selection: $currentTab) {
                CurrentTab.about.label
            }
        }
        .listStyle(SidebarListStyle())
        .listItemTint(.fixed(.red))
        .navigationTitle("Расписание")
    }
}

struct SchedulePlaceholder: View {
    var body: some View {
        Text("Please select schedule to view...")
    }
}

private extension View {
    func tab(_ tab: CurrentTab) -> some View {
        self
            .tabItem { tab.label }
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
            Label("О приложении", systemImage: "wrench")
        }
    }
}

private extension RequestsManager.Logger {

    static let osLog = Self(constructRequest: { request in
        os_log(.debug, log: .targetRequest, "%@", request.curlDescription)
    })
}

private extension OSLog {

    static let targetRequest = bsuirSchedule(category: "TargetRequest")
}

private extension URLRequest {

    var curlDescription: String {
        guard let url = url else { return "[Unknown]" }

        let body = httpBody
            .flatMap { String(data: $0, encoding: .utf8) }
            .map { "-d '\($0)'" }

        let headers = allHTTPHeaderFields?
            .map { "-H '\($0.0): \($0.1)'" }

        let components = ["curl", url.absoluteString] + ([body].compactMap { $0 }) + (headers ?? [])

        return components.joined(separator: " ")
    }
}
