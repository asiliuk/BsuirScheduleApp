import Foundation
import ComposableArchitecture
import BsuirApi

@Reducer
public struct ScheduleListFeature {
    public enum Loading {
        case loadMore
        case finished
        case never
    }

    @ObservableState
    public struct State {
        let scheduleType: ScheduleDisplayType
        var hasSchedule: Bool { !days.isEmpty }
        var days: IdentifiedArrayOf<DaySectionFeature.State>
        var loading: Loading
        var title: LocalizedStringResource?
        var subtitle: LocalizedStringResource?
    }

    @CasePathable
    public enum Action {
        public enum Delegate {
            case loadMore
            case showGroupSchedule(String)
            case showLectorSchedule(Employee)
            case changeScheduleType(ScheduleDisplayType)
        }

        case loadingIndicatorAppeared
        case checkScheduleTapped
        case days(IdentifiedActionOf<DaySectionFeature>)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadingIndicatorAppeared:
                return .send(.delegate(.loadMore))

            case .checkScheduleTapped:
                return .send(.delegate(.changeScheduleType(.compact)))

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
