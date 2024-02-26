import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi

public enum PairRowDetails {
    case lecturers
    case groups
}

public enum PairRowDay: Equatable {
    case date(Date?)
    case weekday(DaySchedule.WeekDay)
}

@Reducer
public struct PairRowFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID { pair.id }
        var isFiltered: Bool = false
        var pair: PairViewModel
        var showWeeks: Bool
        var details: PairRowDetails?
        var day: PairRowDay
        @Presents var pairDetails: PairDetailsFeature.State?

        public init(
            pair: PairViewModel,
            showWeeks: Bool,
            details: PairRowDetails?,
            day: PairRowDay
        ) {
            self.pair = pair
            self.showWeeks = showWeeks
            self.details = details
            self.day = day
        }
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showGroupSchedule(String)
            case showLectorSchedule(Employee)
        }

        case rowTapped
        case pairDetails(PresentationAction<PairDetailsFeature.Action>)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .rowTapped:
                state.pairDetails = PairDetailsFeature.State(
                    pair: state.pair,
                    rowDetails: state.details,
                    rowDay: state.day
                )
                return .none
            case .pairDetails(.presented(.delegate(let action))):
                state.pairDetails = nil
                switch action {
                case .showGroupSchedule(let name):
                    return .send(.delegate(.showGroupSchedule(name)))
                case .showLectorSchedule(let employee):
                    return .send(.delegate(.showLectorSchedule(employee)))
                }

            case .delegate, .pairDetails:
                return .none
            }
        }
        .ifLet(\.$pairDetails, action: \.pairDetails) {
            PairDetailsFeature()
        }
    }
}
