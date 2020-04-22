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

struct AllGroupsScreenGroup: Identifiable, Comparable {

    var id: Int { group.id }
    var name: String { group.name }

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.name < rhs.name }

    fileprivate init(group: Group) { self.group = group }
    fileprivate let group: Group
}

final class AllGroupsScreen: ObservableObject {

    @Published var searchQuery: String = ""
    let groups: LoadableContent<[AllGroupsScreenGroup]>

    let requestManager: RequestsManager
    init(requestManager: RequestsManager) {
        self.requestManager = requestManager
        self.groups = LoadableContent(
            requestManager
                .request(BsuirTargets.Groups())
                .log(.appState, identifier: "All groups")
                .map { $0.map(AllGroupsScreenGroup.init).sorted() }
                .combineLatest(
                    _searchQuery.projectedValue
                        .debounce(for: 0.2, scheduler: RunLoop.main)
                        .setFailureType(to: RequestsManager.RequestError.self)
                )
                .map { groups, query in
                    guard !query.isEmpty else { return groups }
                    return groups.filter { $0.name.starts(with: query) }
                }
                .eraseToLoading()
        )
    }

    func screen(for group: AllGroupsScreenGroup) -> ScheduleScreen {
        .group(group.group, requestManager: requestManager)
    }

    private var cancellables = Set<AnyCancellable>()
}
