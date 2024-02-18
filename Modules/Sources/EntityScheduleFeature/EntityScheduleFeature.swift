import Foundation
import Favorites
import ScheduleCore
import BsuirApi
import ComposableArchitecture
import Deeplinking
import ScheduleFeature

@Reducer
public struct EntityScheduleFeature {
    @ObservableState
    public enum State: Equatable {
        case group(GroupScheduleFeature.State)
        case lector(LectorScheduleFeature.State)

        public var title: String {
            switch self {
            case let .group(schedule): schedule.groupName
            case let .lector(schedule): schedule.lector.compactFio
            }
        }
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
            case .group(.schedule(.delegate(let action))),
                 .lector(.schedule(.delegate(let action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showGroupSchedule(let name):
                    return .send(.delegate(.showGroupSchedule(name)))
                case .showLectorSchedule(let employee):
                    return .send(.delegate(.showLectorSchedule(employee)))
                }

            case .delegate, .group, .lector:
                return .none
            }
        }

        Scope(state: \.group, action: \.group) {
            GroupScheduleFeature()
        }

        Scope(state: \.lector, action: \.lector) {
            LectorScheduleFeature()
        }
    }
}
