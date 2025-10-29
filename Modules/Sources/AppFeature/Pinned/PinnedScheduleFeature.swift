import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import ScheduleCore
import ScheduleFeature

@Reducer
public struct PinnedScheduleFeature {
    @ObservableState
    public struct State {
        var title: String {
            switch entitySchedule {
            case let .group(schedule): schedule.groupName
            case let .lector(schedule): schedule.lector.compactFio
            }
        }
        var entitySchedule: EntityScheduleFeatureV2.State
        var path = StackState<EntityScheduleFeatureV2.State>()

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

        case entitySchedule(EntityScheduleFeatureV2.Action)
        case path(StackAction<EntityScheduleFeatureV2.State, EntityScheduleFeatureV2.Action>)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.entitySchedule, action: \.entitySchedule) {
            EntityScheduleFeatureV2.body
        }

        Reduce { state, action in
            switch action {
            case .path(.element(_, .group(.schedule(.delegate(let action))))),
                 .path(.element(_, .lector(.schedule(.delegate(let action))))),
                 .entitySchedule(.group(.schedule(.delegate(let action)))),
                 .entitySchedule(.lector(.schedule(.delegate(let action)))):
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
        .forEach(\.path, action: \.path)
    }
}
