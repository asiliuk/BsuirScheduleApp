import Foundation
import ComposableArchitecture
import BsuirApi

@Reducer
public struct ScheduleListFeature {
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

    @CasePathable
    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case loadMore
            case showGroupSchedule(String)
            case showLectorSchedule(Employee)
        }

        case loadingIndicatorAppeared
        case setIsOnTop(Bool)
        case days(IdentifiedActionOf<DaySectionFeature>)
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

            case .days(.element(_, action: .pairRows(.element(_ , .delegate(let action))))):
                switch action {
                case .showGroupSchedule(let groupName):
                    return .send(.delegate(.showGroupSchedule(groupName)))

                case .showLectorSchedule(let employee):
                    return .send(.delegate(.showLectorSchedule(employee)))
                }

            case .days, .delegate:
                return .none
            }
        }
        .forEach(\.days, action: \.days) {
            DaySectionFeature()
        }
    }
}
