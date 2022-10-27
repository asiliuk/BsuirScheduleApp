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
import SwiftUI
import Favorites

struct AllLecturersScreenLecturer: Identifiable, Equatable {
    var id: Int { employee.id }
    var fullName: String { employee.fio }
    var imageURL: URL? { employee.photoLink }

    init(employee: Employee) { self.employee = employee }
    let employee: Employee
}

final class AllLecturersScreen: ObservableObject {

    @Published var searchQuery: String = ""
    @Published var selectedLecturer: AllLecturersScreenLecturer?
    let lecturers: LoadableContent<[AllLecturersScreenGroupSection]>

    init(
        requestManager: RequestsManager,
        favorites: FavoritesContainer,
        deeplinkHandler: DeeplinkHandler
    ) {
        self.requestManager = requestManager
        self.favorites = favorites
        self.lecturers = LoadableContent(
            requestManager.request(BsuirIISTargets.Employees())
                .map { $0.map(AllLecturersScreenLecturer.init) }
                .query(by: _searchQuery.projectedValue) { lecturers, query in
                    guard !query.isEmpty else { return lecturers }
                    return lecturers.filter { $0.fullName.lowercased().contains(query.lowercased()) }
                }
                .combineLatest(
                    favorites.lecturers
                        .setFailureType(to: RequestsManager.RequestError.self)
                )
                .map { .init(lecturers: $0, favorites: $1) }
                .eraseToLoading()
        )

        deeplinkHandler.deeplink(autoresolve: true)
            .compactMap { deeplink -> Int? in
                guard case let .lecturers(id?) = deeplink else {
                    return nil
                }

                return id
            }
            .flatMap { [lecturers] id in
                lecturers.$state
                    .filter { !$0.inProgress }
                    .first()
                    .map { $0.some?.flatMap(\.lecturers).first(where: { $0.id == id }) }
            }
            .assign(to: &$selectedLecturer)

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
