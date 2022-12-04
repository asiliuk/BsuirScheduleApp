import Foundation
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct DayScheduleFeature: ReducerProtocol {
    public struct State: Equatable {
        var days: [ScheduleDayViewModel] = []
        fileprivate var schedule: DaySchedule
        
        init(schedule: DaySchedule) {
            self.schedule = schedule
        }
    }

    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case onAppear
        }

        public typealias ReducerAction = Never
        public typealias DelegateAction = Never

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
            case .view(.onAppear) where state.days.isEmpty:
                loadDays(&state)
                return .none
                
            case .view:
                return .none
            }
        }
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
                title: weekday.localizedName(in: calendar).capitalized,
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
