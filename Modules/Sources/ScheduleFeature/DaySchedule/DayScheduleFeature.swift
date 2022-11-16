import Foundation
import BsuirCore
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct DayScheduleFeature: ReducerProtocol {
    public struct State: Equatable {
        var days: [ScheduleDayViewModel] = []
        @BindableState var isOnTop = false
        fileprivate var schedule: DaySchedule
        
        init(schedule: DaySchedule) {
            self.schedule = schedule
        }
    }

    public enum Action: Equatable, FeatureAction, BindableAction {
        public enum ViewAction: Equatable {
            case task
        }

        public typealias ReducerAction = Never
        public typealias DelegateAction = Never

        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.task) where state.days.isEmpty:
                loadDays(&state)
                return .none
                
            case .view, .binding:
                return .none
            }
        }
        
        BindingReducer()
    }
    
    private func loadDays(_ state: inout State) {
        state.days = DaySchedule.WeekDay.allCases
            .compactMap { weekday in
            guard
                let pairs = state.schedule[weekday],
                !pairs.isEmpty
            else { return nil }

            return ScheduleDayViewModel(
                id: uuid(),
                title: calendar.localizedWeekdayName(weekday).capitalized,
                pairs: pairViewModels(pairs)
            )
        }
    }

    private func pairViewModels(_ pairs: [Pair]) -> [PairViewModel] {
        pairs.map {
            PairViewModel(
                start: calendar.date(bySetting: $0.startLessonTime, of: now),
                end: calendar.date(bySetting: $0.endLessonTime, of: now),
                pair: $0
            )
        }
    }
}

private extension Calendar {
    func localizedWeekdayName(_ weekday: DaySchedule.WeekDay) -> String {
        let index = (weekday.weekdayIndex + firstWeekday - 1) % 7
        return weekdaySymbols[index]
    }
}
