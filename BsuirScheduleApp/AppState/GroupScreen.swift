//
//  GroupScreen.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/7/20.
//  Copyright © 2020 Saute. All rights reserved.
//
import BsuirApi
import Combine
import Foundation

extension ScheduleScreen {

    static func group(_ group: Group, requestManager: RequestsManager) -> Self {
        Self(
            name: group.name,
            request: requestManager
                .request(BsuirTargets.Schedule(agent: .groupID(group.id)))
                .map(\.schedules)
                .log(.appState, identifier: "Days")
                .eraseToAnyPublisher()
        )
    }
}
