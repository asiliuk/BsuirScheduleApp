import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import ScheduleCore
import ScheduleFeature

@Reducer
public struct PinnedScheduleFeature {
    @ObservableState
    public struct State {
        var title: String { entitySchedule.title }
        var entitySchedule: EntityScheduleFeature.State
        var path = StackState<EntityScheduleFeature.State>()

        init(pinned: ScheduleSource) {
            switch pinned {
            case .group(let name):
                entitySchedule = .group(.init(groupName: name, showScheduleMark: false))
            case .lector(let employee):
                entitySchedule = .lector(.init(lector: employee, showScheduleMark: false))
            }
        }
    }

    public enum Action {
        public enum Delegate {
            case showPremiumClubPinned
        }

        case entitySchedule(EntityScheduleFeature.Action)
        case path(StackAction<EntityScheduleFeature.State, EntityScheduleFeature.Action>)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.entitySchedule, action: \.entitySchedule) {
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
        .forEach(\.path, action: \.path) {
            EntityScheduleFeature()
        }
    }
}
