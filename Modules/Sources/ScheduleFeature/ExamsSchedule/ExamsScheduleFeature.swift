import Foundation
import BsuirCore
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct ExamsScheduleFeature: ReducerProtocol {
    public struct State: Equatable {
        var days: [ScheduleDayViewModel] = []
        fileprivate var exams: [Pair]
        fileprivate let startDate: Date?
        fileprivate let endDate: Date?
        
        init(exams: [Pair], startDate: Date?, endDate: Date?) {
            self.exams = exams
            self.startDate = startDate
            self.endDate = endDate
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

    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .view(.onAppear):
            loadExamDays(state: &state)
            return .none
        }
    }

    private func loadExamDays(state: inout State) {
        state.days = Dictionary(grouping: state.exams, by: \.dateLesson)
            .sorted(by: optionalSort(\.key))
            .map { ScheduleDayViewModel(id: uuid(), date: $0, now: now, pairs: $1, calendar: calendar) }
    }
}

private extension ScheduleDayViewModel {
    init(id: UUID, date: Date?, now: Date, pairs: [Pair], calendar: Calendar) {
        assert(date != nil, "Not really expecting days without date")

        self.init(
            id: id,
            title: date?.formatted(.examDay) ?? "-/-",
            pairs: pairs.map { pair in
                let start = calendar.date(bySetting: pair.startLessonTime, of: date ?? now)
                let end = calendar.date(bySetting: pair.endLessonTime, of: date ?? now)
                return (start, end, pair)
            }
            .sorted(by: optionalSort(\.0))
            .map { PairViewModel(start: $0, end: $1, pair: $2, showWeeks: false) }
        )
    }
}

private func optionalSort<T, V: Comparable>(_ keyPath: KeyPath<T, V?>) -> (T, T) -> Bool {
    return { lhs, rhs in
        switch (lhs[keyPath: keyPath], rhs[keyPath: keyPath]) {
        case (nil, nil): return false
        case (nil,.some): return true
        case (.some, nil): return false
        case let (lhs?, rhs?): return lhs < rhs
        }
    }
}
