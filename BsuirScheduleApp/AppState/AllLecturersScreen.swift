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

final class AllLecturersScreen: ObservableObject {

    @Published var searchQuery: String = ""
    let lecturers: LoadableContent<[AllLecturersScreenLecturer]>

    init(requestManager: RequestsManager) {
        self.requestManager = requestManager
        self.lecturers = LoadableContent(
            requestManager.request(BsuirTargets.Employees())
                .map { $0.map(AllLecturersScreenLecturer.init) }
                .query(by: _searchQuery.projectedValue) { lecturers, query in
                    guard !query.isEmpty else { return lecturers }
                    return lecturers.filter { $0.fullName.lowercased().contains(query.lowercased()) }
                }
                .eraseToLoading()
        )
    }

    func screen(for lecturer: AllLecturersScreenLecturer) -> ScheduleScreen {
        .lecturer(lecturer.employee, requestManager: requestManager)
    }

    func image(for lecturer: AllLecturersScreenLecturer) -> RemoteImage {
        .remoteImage(
            requestManager: requestManager,
            url: lecturer.employee.photoLink
        )
    }

    private let requestManager: RequestsManager
}

extension Publisher {

    func query<Query>(
        by query: Query,
        transform: @escaping (Output, Query.Output) -> Output
    ) -> AnyPublisher<Output, Failure>
    where Query: Publisher, Query.Output: Equatable, Query.Failure == Never
    {
        self.combineLatest(
                query
                    .debounce(for: 0.2, scheduler: RunLoop.main)
                    .removeDuplicates()
                    .setFailureType(to: Failure.self)
            )
            .map(transform)
            .eraseToAnyPublisher()
    }
}
