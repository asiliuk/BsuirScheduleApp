//
//  LecturerScreen.swift
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

    static func lecturer(_ employee: Employee, favorites: FavoritesContainer, requestManager: RequestsManager) -> Self {
        Self(
            name: employee.fio,
            isFavorite: favorites.lecturers
                .map { $0.contains(employee) }
                .removeDuplicates()
                .eraseToAnyPublisher(),
            toggleFavorite: { favorites.toggle(lecturer: employee) },
            request: requestManager
                .request(BsuirIISTargets.EmployeeSchedule(urlId: employee.urlId))
                .map { ($0.schedules ?? DaySchedule(), $0.examSchedules ?? []) }
                .eraseToAnyPublisher(),
            employeeSchedule: nil,
            groupSchedule: { .group(name: $0, favorites: favorites, requestManager: requestManager) }
        )
    }
}
