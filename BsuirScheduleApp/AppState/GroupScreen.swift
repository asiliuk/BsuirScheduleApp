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

extension ScheduleScreen {

    static func group(_ group: Group, favorites: FavoritesContainer, requestManager: RequestsManager) -> Self {
        Self(
            name: group.name,
            isFavorite: favorites.$groups
                .map { $0.contains(group.id) }
                .removeDuplicates()
                .eraseToAnyPublisher(),
            toggleFavorite: { favorites.toggleGroupFavorite(id: group.id) },
            request: requestManager
                .request(BsuirTargets.Schedule(agent: .groupID(group.id)))
                .map { ($0.schedules, $0.examSchedules) }
                .log(.appState, identifier: "Days")
                .eraseToAnyPublisher()
        )
    }
}
