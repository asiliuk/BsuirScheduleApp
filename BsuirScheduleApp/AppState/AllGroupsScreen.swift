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

final class FavoritesContainer {
    @Published private(set) var groups: Set<Int> {
        didSet { storage.set(groups.sorted(), forKey: groupsKey) }
    }

    @Published private(set) var lecturers: Set<Int> {
        didSet { storage.set(lecturers.sorted(), forKey: lecturersKey) }
    }

    init(storage: UserDefaults) {
        self.storage = storage
        self.groups = Set(storage.object(forKey: groupsKey) as? [Int] ?? [])
        self.lecturers = Set(storage.object(forKey: lecturersKey) as? [Int] ?? [])
    }

    func toggleGroupFavorite(id: Int) {
        if groups.contains(id) {
            groups.remove(id)
        } else {
            groups.insert(id)
        }
    }

    func toggleLecturerFavorite(id: Int) {
        if lecturers.contains(id) {
            lecturers.remove(id)
        } else {
            lecturers.insert(id)
        }
    }

    private let groupsKey = "favorite-group-ids"
    private let lecturersKey = "favorite-lecturer-ids"
    private let storage: UserDefaults
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
                .combineLatest(favorites.$groups.setFailureType(to: RequestsManager.RequestError.self))
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
    init(favorites: Set<Int>, groups: [Group]) {
        let favoritesGroup = AllGroupsScreenGroupSection(
            title: "⭐️ Избранные",
            groups: groups
                .filter { favorites.contains($0.id) }
                .sorted { $0.name < $1.name }
                .map(AllGroupsScreenGroup.init)
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
