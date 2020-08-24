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
    init(requestManager: RequestsManager) { self.requestManager = requestManager }

    private lazy var favorites = FavoritesContainer(storage: .standard)
    private(set) lazy var allFavorites = AllFavoritesScreen(requestManager: requestManager, favorites: favorites)
    private(set) lazy var allGroups = AllGroupsScreen(requestManager: requestManager, favorites: favorites)
    private(set) lazy var allLecturers = AllLecturersScreen(requestManager: requestManager, favorites: favorites)
}

final class AllFavoritesScreen: ObservableObject {
    var isEmpty: Bool { groups.isEmpty && lecturers.isEmpty }
    @Published private(set) var groups: [AllGroupsScreenGroup] = []
    @Published private(set) var lecturers: [AllLecturersScreenLecturer] = []

    init(requestManager: RequestsManager, favorites: FavoritesContainer) {
        self.favorites = favorites
        self.requestManager = requestManager
        favorites.$groups.map { $0.value.map(AllGroupsScreenGroup.init) }.assign(to: &$groups)
        favorites.$lecturers.map { $0.value.map(AllLecturersScreenLecturer.init) }.assign(to: &$lecturers)
    }

    func screen(for group: AllGroupsScreenGroup) -> ScheduleScreen {
        .group(group.group, favorites: favorites, requestManager: requestManager)
    }

    func screen(for lecturer: AllLecturersScreenLecturer) -> ScheduleScreen {
        .lecturer(lecturer.employee, favorites: favorites, requestManager: requestManager)
    }

    private let favorites: FavoritesContainer
    private let requestManager: RequestsManager
}
