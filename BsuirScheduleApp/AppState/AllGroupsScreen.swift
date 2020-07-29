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

final class AllGroupsScreen: ObservableObject {

    @Published var searchQuery: String = ""
    let groups: LoadableContent<[AllGroupsScreenGroupSection]>

    let requestManager: RequestsManager
    init(requestManager: RequestsManager) {
        self.requestManager = requestManager
        self.groups = LoadableContent(
            requestManager
                .request(BsuirTargets.Groups())
                .log(.appState, identifier: "All groups")
                .query(by: _searchQuery.projectedValue) { groups, query in
                    guard !query.isEmpty else { return groups }
                    return groups.filter { $0.name.starts(with: query) }
                }
                .map { .init($0) }
                .eraseToLoading()
        )
    }

    func screen(for group: AllGroupsScreenGroup) -> ScheduleScreen {
        .group(group.group, requestManager: requestManager)
    }

    private var cancellables = Set<AnyCancellable>()
}

extension Array where Element == AllGroupsScreenGroupSection {
    init(_ groups: [Group]) {
        let groupedGroups = Dictionary(grouping: groups, by: { $0.name.prefix(3) })
        self = groupedGroups
            .sorted(by: { $0.key < $1.key })
            .map { title, groups in
                AllGroupsScreenGroupSection(
                    title: String(title),
                    groups: groups
                        .sorted { $0.name < $1.name }
                        .map(AllGroupsScreenGroup.init)
                )
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
