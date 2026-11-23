import Foundation
import ScheduleCore
import ComposableArchitecture

@Reducer
struct LoadedScheduleFeature {
    @ObservableState
    struct State {
        let source: ScheduleSource
        let response: ScheduleRequestResponse
        var viewOptions: ScheduleViewOptionsFeature.State

        var continuous: ContinuousScheduleFeature.State
        var day: DayScheduleFeature.State
        var exams: ExamsScheduleFeature.State

        @Shared var sharedNow: Date

        init(source: ScheduleSource, response: ScheduleRequestResponse) {
            self.source = source
            self.response = response

            @Dependency(\.date.now) var now
            self._sharedNow = Shared(value: now)

            let continuous = ContinuousScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate,
                sharedNow: _sharedNow
            )
            self.continuous = continuous

            self.day = DayScheduleFeature.State(
                daySchedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate,
                sharedNow: _sharedNow
            )

            let exams = ExamsScheduleFeature.State(
                exams: response.exams,
                startDate: response.startExamsDate,
                endDate: response.endExamsDate,
                sharedNow: _sharedNow
            )
            self.exams = exams

            self.viewOptions = ScheduleViewOptionsFeature.State(
                source: source,
                hasSchedule: !continuous.days.isEmpty,
                hasExams: !exams.days.isEmpty,
                maxSubgroup: response.maxSubgroup
            )

        }
    }

    enum Action {
        case onAppear
        case continuous(ContinuousScheduleFeature.Action)
        case day(DayScheduleFeature.Action)
        case exams(ExamsScheduleFeature.Action)
        case viewOptions(ScheduleViewOptionsFeature.Action)
    }

    @Dependency(\.date.now) var now

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.$sharedNow.withLock { $0 = now }
                return .none
            case .exams(.delegate(let action)):
                switch action {
                case .switchToSchedule:
                    state.viewOptions.displayType = .compact
                    return .none
                }
            case .continuous, .day, .exams, .viewOptions:
                return .none
            }
        }

        Scope(\.viewOptions, action: \.viewOptions) {
            ScheduleViewOptionsFeature()
        }

        Scope(\.continuous, action: \.continuous) {
            ContinuousScheduleFeature()
        }

        Scope(\.day, action: \.day) {
            DayScheduleFeature()
        }

        Scope(\.exams, action: \.exams) {
            ExamsScheduleFeature()
        }
    }
}
