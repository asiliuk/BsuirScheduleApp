import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi

public struct PairDetailsFeature: Reducer {
    public struct State: Equatable {
        var pair: PairViewModel
        var rowDetails: PairRowDetails?
        var rowDay: PairRowDay
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showGroupSchedule(String)
            case showLectorSchedule(Employee)
        }

        case closeButtonTapped
        case groupTapped(String)
        case lectorTapped(Employee)
        case delegate(Delegate)
    }

    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .run { _ in await dismiss() }

            case .groupTapped(let name):
                return .send(.delegate(.showGroupSchedule(name)))

            case .lectorTapped(let employee):
                return .send(.delegate(.showLectorSchedule(employee)))

            case .delegate:
                return .none
            }
        }
    }
}
