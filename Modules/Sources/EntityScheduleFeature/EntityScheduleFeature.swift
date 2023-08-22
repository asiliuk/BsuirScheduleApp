import Foundation
import Favorites
import ScheduleCore
import BsuirApi
import ComposableArchitecture

public struct EntityScheduleFeature: Reducer {
    public enum State: Equatable {
        case group(GroupScheduleFeature.State)
        case lector(LectorScheduleFeature.State)
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showPremiumClubPinned
            case showLectorSchedule(Employee)
            case showGroupSchedule(String)
        }

        case group(GroupScheduleFeature.Action)
        case lector(LectorScheduleFeature.Action)
        case delegate(Delegate)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .group(.delegate(let action)):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showLectorSchedule(let employee):
                    return .send(.delegate(.showLectorSchedule(employee)))
                }

            case .lector(.delegate(let action)):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showGroupSchedule(let name):
                    return .send(.delegate(.showGroupSchedule(name)))
                }

            case .delegate, .group, .lector:
                return .none
            }
        }

        Scope(state: /State.group, action: /Action.group) {
            GroupScheduleFeature()
        }

        Scope(state: /State.lector, action: /Action.lector) {
            LectorScheduleFeature()
        }
    }
}

extension EntityScheduleFeature.State {
    public var title: String {
        switch self {
        case let .group(schedule):
            return schedule.groupName
        case let .lector(schedule):
            return schedule.lector.compactFio
        }
    }
}

extension EntityScheduleFeature.State {
    public mutating func reset() {
        try? (/Self.group).modify(&self) { $0.schedule.reset() }
        try? (/Self.lector).modify(&self) { $0.schedule.reset() }
    }
}
