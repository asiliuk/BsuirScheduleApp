//
//  GroupScreen.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/7/20.
//  Copyright © 2020 Saute. All rights reserved.
//
import BsuirApi
import Combine
import Foundation
import Favorites

extension ScheduleScreen {

    static func group(_ group: StudentGroup, favorites: FavoritesContainer, requestManager: RequestsManager) -> Self {
        Self(
            name: group.name,
            isFavorite: favorites.groups
                .map { $0.contains(group) }
                .removeDuplicates()
                .eraseToAnyPublisher(),
            toggleFavorite: { favorites.toggle(group: group) },
            request: requestManager
                .request(BsuirIISTargets.GroupSchedule(groupNumber: group.name))
                .map(ScheduleScreen.RequestResponse.init)
                .log(.appState, identifier: "Days")
                .eraseToAnyPublisher(),
            employeeSchedule: { .lecturer($0, favorites: favorites, requestManager: requestManager) },
            groupSchedule: nil
        )
    }

    static func group(name: String, favorites: FavoritesContainer, requestManager: RequestsManager) -> Self {
        Self(
            name: name,
            isFavorite: Just(false).eraseToAnyPublisher(),
            toggleFavorite: nil,
            request: requestManager
                .request(BsuirIISTargets.GroupSchedule(groupNumber: name))
                .map(ScheduleScreen.RequestResponse.init)
                .log(.appState, identifier: "Days")
                .eraseToAnyPublisher(),
            employeeSchedule: { .lecturer($0, favorites: favorites, requestManager: requestManager) },
            groupSchedule: nil
        )
    }
}

private extension ScheduleScreen.RequestResponse {
    init(response: BsuirIISTargets.GroupSchedule.Value) {
        self.init(
            startDate: response.startDate,
            endDate: response.endDate,
            startExamsDate: response.startExamsDate,
            endExamsDate: response.endExamsDate,
            schedule: response.schedules,
            exams: response.examSchedules
        )
    }
}
