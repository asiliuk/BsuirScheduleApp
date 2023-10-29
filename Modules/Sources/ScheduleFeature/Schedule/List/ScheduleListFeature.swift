import Foundation
import ComposableArchitecture
import BsuirApi

public struct ScheduleListFeature: Reducer {
    public enum Loading: Equatable {
        case loadMore
        case finished
        case never
    }

    public struct State: Equatable {
        var isOnTop: Bool = true
        var hasSchedule: Bool { !days.isEmpty }
        var days: IdentifiedArrayOf<DaySectionFeature.State>
        var loading: Loading
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case loadMore
            case showGroupSchedule(String)
            case showLectorSchedule(Employee)
        }

        case loadingIndicatorAppeared
        case setIsOnTop(Bool)
        case day(id: DaySectionFeature.State.ID, action: DaySectionFeature.Action)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setIsOnTop(let value):
                state.isOnTop = value
                return .none

            case .loadingIndicatorAppeared:
                return .send(.delegate(.loadMore))

            case .day(_, action: .pairRow(_ , .delegate(let action))):
                switch action {
                case .showGroupSchedule(let groupName):
                    return .send(.delegate(.showGroupSchedule(groupName)))

                case .showLectorSchedule(let employee):
                    return .send(.delegate(.showLectorSchedule(employee)))
                }

            case .day, .delegate:
                return .none
            }
        }
        .forEach(\.days, action: /Action.day) {
            DaySectionFeature()
        }
    }
}

// MARK: - Filter

extension ScheduleListFeature.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        days.filter(keepingSubgroup: subgroup)
    }
}

extension MutableCollection where Element == DaySectionFeature.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        for index in indices {
            self[index].filter(keepingSubgroup: subgroup)
        }
    }
}
