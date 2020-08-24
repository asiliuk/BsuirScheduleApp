//
//  AllGroupsScreen.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/7/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import BsuirApi
import Combine
import Foundation

struct FavoritesValue<F: Codable & Equatable> {
    private(set) var value: [F]

    init(storage: UserDefaults, key: String) {
        self.storage = storage
        self.key = key
        self.value = []
        self.value = self.fetch()
    }

    mutating func toggle(_ favorite: F) {
        if value.contains(favorite) {
            value.removeAll(where: { $0 == favorite })
        } else {
            value.append(favorite)
        }
    }

    private func save(_ favorites: [F]) {
        storage.set(try? encoder.encode(favorites), forKey: key)
    }

    private func fetch() -> [F] {
        guard
            let data = storage.data(forKey: key),
            let favorites = try? decoder.decode([F].self, from: data)
        else { return [] }
        return favorites
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storage: UserDefaults
    private let key: String
}

final class FavoritesContainer {
    @Published var groups: FavoritesValue<Group>
    @Published var lecturers: FavoritesValue<Employee>

    init(storage: UserDefaults) {
        self.groups = FavoritesValue(storage: storage, key: "favorite-groups")
        self.lecturers = FavoritesValue(storage: storage, key: "favorite-lecturers")
    }
}

final class AllGroupsScreen: ObservableObject {

    @Published var searchQuery: String = ""
    let groups: LoadableContent<[AllGroupsScreenGroupSection]>

    let requestManager: RequestsManager
    init(requestManager: RequestsManager, favorites: FavoritesContainer) {
        self.requestManager = requestManager
        self.favorites = favorites
        self.groups = LoadableContent(
            requestManager
                .request(BsuirTargets.Groups())
                .log(.appState, identifier: "All groups")
                .query(by: _searchQuery.projectedValue) { groups, query in
                    guard !query.isEmpty else { return groups }
                    return groups.filter { $0.name.starts(with: query) }
                }
                .combineLatest(
                    favorites.$groups
                        .map { $0.value }
                        .setFailureType(to: RequestsManager.RequestError.self)
                )
                .map { .init(favorites: $1, groups: $0) }
                .eraseToLoading()
        )
    }

    func screen(for group: AllGroupsScreenGroup) -> ScheduleScreen {
        .group(group.group, favorites: favorites, requestManager: requestManager)
    }

    private let favorites: FavoritesContainer
    private var cancellables = Set<AnyCancellable>()
}

extension Array where Element == AllGroupsScreenGroupSection {
    init(favorites: [Group], groups: [Group]) {
        let favoritesGroup = AllGroupsScreenGroupSection(
            title: "⭐️ Избранные",
            groups: favorites.map(AllGroupsScreenGroup.init)
        )

        let groupedGroups = Dictionary(grouping: groups, by: { $0.name.prefix(3) })
        let rest = groupedGroups
            .sorted(by: { $0.key < $1.key })
            .map { title, groups in
                AllGroupsScreenGroupSection(
                    title: String(title),
                    groups: groups
                        .sorted { $0.name < $1.name }
                        .map(AllGroupsScreenGroup.init)
                )
            }

        if favoritesGroup.groups.isEmpty {
            self = rest
        } else {
            self = [favoritesGroup] + rest
        }
    }
}

struct AllGroupsScreenGroupSection: Identifiable {
    var id: String { title }
    let title: String
    let groups: [AllGroupsScreenGroup]
}

struct AllGroupsScreenGroup: Identifiable {
    var id: Int { group.id }
    var name: String { group.name }

    fileprivate init(group: Group) { self.group = group }
    fileprivate let group: Group
}
