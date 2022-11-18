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
import Favorites

final class AllGroupsScreen: ObservableObject {

    @Published var searchQuery: String = ""
    @Published var selectedGroup: AllGroupsScreenGroup?
    let groups: LoadableContent<[AllGroupsScreenGroupSection]>

    let requestManager: RequestsManager
    init(
        requestManager: RequestsManager,
        favorites: FavoritesContainer,
        deeplinkHandler: DeeplinkHandler
    ) {
        self.requestManager = requestManager
        self.favorites = favorites
        self.groups = LoadableContent(
            requestManager
                .request(BsuirIISTargets.StudentGroups())
                .log(.appState, identifier: "All groups")
                .query(by: _searchQuery.projectedValue) { groups, query in
                    guard !query.isEmpty else { return groups }
                    return groups.filter { $0.name.starts(with: query) }
                }
                .combineLatest(
                    favorites.groupNames
                        .setFailureType(to: RequestsManager.RequestError.self)
                )
                .map { .init(favorites: $1, groups: $0) }
                .eraseToLoading()
        )

        deeplinkHandler.deeplink(autoresolve: true)
            .compactMap { deeplink -> String? in
                guard case let .groups(id?) = deeplink else {
                    return nil
                }

                return String(id)
            }
            .flatMap { [groups] id in
                groups.$state
                    .filter { !$0.inProgress }
                    .first()
                    .map { $0.some?.flatMap(\.groups).first(where: { $0.id == id }) }
            }
            .assign(to: &$selectedGroup)
    }

    func screen(for group: AllGroupsScreenGroup) -> ScheduleScreen {
        .group(name: group.name, favorites: favorites, requestManager: requestManager)
    }

    private let favorites: FavoritesContainer
    private var cancellables = Set<AnyCancellable>()
}

extension Array where Element == AllGroupsScreenGroupSection {
    init(favorites: [String], groups: [StudentGroup]) {
        let favoritesGroup = AllGroupsScreenGroupSection(
            title: String(localized: "screen.groups.favorites.section.header"),
            groups: favorites.map(AllGroupsScreenGroup.init)
        )

        let groupedGroups = Dictionary(grouping: groups, by: { $0.name.prefix(3) })
        let rest = groupedGroups
            .sorted(by: { $0.key < $1.key })
            .map { title, groups in
                AllGroupsScreenGroupSection(
                    title: String(title),
                    groups: groups
                        .map(\.name)
                        .sorted(by: <)
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

struct AllGroupsScreenGroup: Identifiable, Equatable {
    var id: String { name }
    var name: String

    init(name: String) { self.name = name }
}
