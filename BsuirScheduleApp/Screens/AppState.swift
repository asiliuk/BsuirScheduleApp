//
//  AppState.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import Foundation
import BsuirApi
import Combine
import UIKit

import os.log

extension OSLog {

    static let appState = bsuirSchedule(category: "AppState")

    static func bsuirSchedule(category: String) -> OSLog {
        OSLog(subsystem: "com.asiliuk.BsuirScheduleApp", category: category)
    }
}

final class AppState: ObservableObject {
    let requestManager: RequestsManager
    init(requestManager: RequestsManager, storage: UserDefaults) {
        self.requestManager = requestManager
        self.storage = storage
    }

    private let storage: UserDefaults
    private(set) lazy var whatsNew = WhatsNewScreen(storage: storage)
    private(set) lazy var favorites = FavoritesContainer(storage: storage)
    private(set) lazy var allFavorites = AllFavoritesScreen(requestManager: requestManager, favorites: favorites)
    private(set) lazy var allGroups = AllGroupsScreen(requestManager: requestManager, favorites: favorites)
    private(set) lazy var allLecturers = AllLecturersScreen(requestManager: requestManager, favorites: favorites)
}
