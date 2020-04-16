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

struct RootView: View {

    @State var state = AppState(requestManager: .bsuir(logger: .osLog))

    var body: some View {
        TabView {
            AllGroupsView(screen: state.allGroups)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Группы")
                }

            AllLecturersView(screen: state.allLecturers)
                .tabItem {
                    Image(systemName: "person.crop.rectangle")
                    Text("Преподаватели")
                }
        }.edgesIgnoringSafeArea(.top)
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

