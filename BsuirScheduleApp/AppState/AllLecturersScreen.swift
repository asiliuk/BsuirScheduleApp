//
//  AllLecturersScreen.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/7/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import BsuirApi
import Combine
import Foundation

struct AllLecturersScreenLecturer: Identifiable {
    var id: Int { employee.id }
    var fullName: String { employee.fio }

    fileprivate init(employee: Employee) { self.employee = employee }
    fileprivate let employee: Employee
}

final class AllLecturersScreen: LoadableContent<[AllLecturersScreenLecturer]> {

    init(requestManager: RequestsManager) {
        self.requestManager = requestManager
        super.init(
            requestManager.request(BsuirTargets.Employees())
                .map { $0.map(AllLecturersScreenLecturer.init) }
                .eraseToLoading()
        )
    }

    func screen(for lecturer: AllLecturersScreenLecturer) -> ScheduleScreen {
        .lecturer(lecturer.employee, requestManager: requestManager)
    }

    func image(for lecturer: AllLecturersScreenLecturer) -> RemoteImage {
        RemoteImage(
            requestManager: requestManager,
            url: lecturer.employee.photoLink
        )
    }

    private let requestManager: RequestsManager
}
