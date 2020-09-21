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
import URLImage
import SwiftUI

struct AllLecturersScreenLecturer: Identifiable {
    var id: Int { employee.id }
    var fullName: String { employee.fio }
    var imageURL: URL? { employee.photoLink }

    init(employee: Employee) { self.employee = employee }
    let employee: Employee
}

final class AllLecturersScreen: ObservableObject {

    @Published var searchQuery: String = ""
    let lecturers: LoadableContent<[AllLecturersScreenGroupSection]>

    init(requestManager: RequestsManager, favorites: FavoritesContainer) {
        self.requestManager = requestManager
        self.favorites = favorites
        self.lecturers = LoadableContent(
            requestManager.request(BsuirTargets.Employees())
                .map { $0.map(AllLecturersScreenLecturer.init) }
                .query(by: _searchQuery.projectedValue) { lecturers, query in
                    guard !query.isEmpty else { return lecturers }
                    return lecturers.filter { $0.fullName.lowercased().contains(query.lowercased()) }
                }
                .combineLatest(
                    favorites.$lecturers
                        .map { $0.value }
                        .setFailureType(to: RequestsManager.RequestError.self)
                )
                .map { .init(lecturers: $0, favorites: $1) }
                .eraseToLoading()
        )
    }

    func screen(for lecturer: AllLecturersScreenLecturer) -> ScheduleScreen {
        .lecturer(lecturer.employee, favorites: favorites, requestManager: requestManager)
    }

    private let favorites: FavoritesContainer
    private let requestManager: RequestsManager
}

private extension Array where Element == AllLecturersScreenGroupSection {
    init(lecturers: [AllLecturersScreenLecturer], favorites: [Employee]) {
        let favoritesGroup = AllLecturersScreenGroupSection(
            section: .favorites,
            lecturers: favorites.map(AllLecturersScreenLecturer.init)
        )

        let otherGroup = AllLecturersScreenGroupSection(
            section: .other,
            lecturers: lecturers
        )

        if favoritesGroup.lecturers.isEmpty {
            self = [otherGroup]
        } else {
            self = [favoritesGroup, otherGroup]
        }
    }
}

struct AllLecturersScreenGroupSection: Identifiable {
    enum Section {
        case favorites
        case other
    }

    var id: Section { section }
    let section: Section
    let lecturers: [AllLecturersScreenLecturer]
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
