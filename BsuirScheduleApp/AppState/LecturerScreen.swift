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

extension ScheduleScreen {

    static func lecturer(_ employee: Employee, requestManager: RequestsManager) -> Self {
        Self(
            name: employee.fio,
            request: requestManager
                .request(BsuirTargets.EmployeeSchedule(id: employee.id))
                .map { $0.schedules ?? [] }
                .eraseToAnyPublisher()
        )
    }
}

extension Employee {

    var fio: String {
        return [lastName, firstName, middleName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
