//
//  AppState.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import Foundation
import BsuirUI
import BsuirApi
import Combine
import UIKit
import Kingfisher
import AboutFeature
import GroupsFeature
import LecturersFeature
import Favorites
import ComposableArchitecture

import os.log

extension OSLog {
    static let appState = bsuirSchedule(category: "AppState")

    static func bsuirSchedule(category: String) -> OSLog {
        OSLog(subsystem: "com.asiliuk.BsuirScheduleApp", category: category)
    }
}

final class AppState: ObservableObject {
    @Published var currentSelection: CurrentSelection?

    init() {
        self.requestManager = .iisBsuir()
        self.favorites.migrateIfNeeded()
        self.currentSelection = .groups
        deeplinkHandler.deeplink()
            .map { deeplink in
                switch deeplink {
                case .groups:
                    return .groups
                case .lecturers:
                    return .lecturers
                }
            }
            .assign(to: &$currentSelection)
    }

    private let storage: UserDefaults = .standard
    private let sharedStorage: UserDefaults = .asiliukShared
    private let requestManager: RequestsManager
    private lazy var favorites = FavoritesContainer(storage: storage)
    private(set) lazy var deeplinkHandler = DeeplinkHandler()
    private(set) lazy var reviewRequestService = ReviewRequestService(storage: storage)
    private(set) lazy var pairFormColorService = PairFormColorService(storage: sharedStorage)

    // MARK: - Screens

    private(set) lazy var aboutStore = Store(
        initialState: .init(),
        reducer: commonDependencies(AboutFeature())
    )
    
    private(set) lazy var groupsStore = Store(
        initialState: .init(),
        reducer: commonDependencies(GroupsFeature())
            
    )
    
    private(set) lazy var lecturersStore = Store(
        initialState: .init(),
        reducer: commonDependencies(LecturersFeature())
    )
    
    private func commonDependencies<R: ReducerProtocol>(_ reducer: R) -> some ReducerProtocol<R.State, R.Action> {
        reducer
            .dependency(\.favorites, favorites)
            .dependency(\.urlCache, requestManager.cache)
            .dependency(\.imageCache, .default)
            .dependency(\.reviewRequestService, reviewRequestService)
            .dependency(\.pairFormColorService, pairFormColorService)
    }
}
