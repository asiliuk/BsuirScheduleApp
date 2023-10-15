import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import ScheduleCore

public struct PinnedScheduleFeature: Reducer {
    public struct State: Equatable {
        var title: String { entitySchedule.title }
        var entitySchedule: EntityScheduleFeature.State
        var path = StackState<EntityScheduleFeature.State>()

        init(pinned: ScheduleSource) {
            switch pinned {
            case .group(let name):
                entitySchedule = .group(.init(groupName: name, showSubgroupPicker: true))
            case .lector(let employee):
                entitySchedule = .lector(.init(lector: employee, showSubgroupPicker: true))
            }
        }
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showPremiumClubPinned
        }

        case entitySchedule(EntityScheduleFeature.Action)
        case path(StackAction<EntityScheduleFeature.State, EntityScheduleFeature.Action>)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.entitySchedule, action: /Action.entitySchedule) {
            EntityScheduleFeature()
        }

        Reduce { state, action in
            switch action {
            case .entitySchedule(.delegate(let action)), .path(.element(_, .delegate(let action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showGroupSchedule(let name):
                    state.path.append(.group(.init(groupName: name)))
                    return .none
                case .showLectorSchedule(let lector):
                    state.path.append(.lector(.init(lector: lector)))
                    return .none
                }
            case .entitySchedule, .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            EntityScheduleFeature()
        }
    }
}

// MARK: - Reset

extension PinnedScheduleFeature.State {
    mutating func reset() {
        entitySchedule.reset()
        path = StackState()
    }
}
