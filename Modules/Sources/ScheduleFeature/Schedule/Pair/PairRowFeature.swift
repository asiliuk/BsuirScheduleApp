import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi

public enum PairRowDetails {
    case lecturers
    case groups
}

public struct PairRowFeature: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: UUID { pair.id }
        var pair: PairViewModel
        var showWeeks: Bool
        var details: PairRowDetails?

        public init(
            pair: PairViewModel,
            showWeeks: Bool,
            details: PairRowDetails?
        ) {
            self.pair = pair
            self.showWeeks = showWeeks
            self.details = details
        }
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showGroupSchedule(String)
            case showLectorSchedule(Employee)
        }

        case lecturerTapped(Employee)
        case groupTapped(String)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .groupTapped(let name):
                return .send(.delegate(.showGroupSchedule(name)))
            case .lecturerTapped(let employee):
                return .send(.delegate(.showLectorSchedule(employee)))
            case .delegate:
                return .none
            }
        }
    }
}
