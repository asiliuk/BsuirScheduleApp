import Foundation
import ComposableArchitecture
import Algorithms
import BsuirApi

public struct LoadedScheduleReducer: Reducer {
    public struct State: Equatable {
        public var maxSubgroup: Int?
        var compact: DayScheduleFeature.State
        var continuous: ContinuousScheduleFeature.State
        var exams: ExamsScheduleFeature.State

        init(response: ScheduleRequestResponse, pairRowDetails: PairRowDetails?) {
            self.compact = DayScheduleFeature.State(
                schedule: response.schedule
            )

            self.continuous = ContinuousScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate,
                pairRowDetails: pairRowDetails
            )

            self.exams = ExamsScheduleFeature.State(
                exams: response.exams,
                startDate: response.startExamsDate,
                endDate: response.endExamsDate,
                pairRowDetails: pairRowDetails
            )

            let allSchedulePairs = DaySchedule.WeekDay.allCases
                .lazy
                .compactMap { response.schedule[$0] }
                .flatMap { $0 }

            let allPairs = chain(allSchedulePairs, response.exams)

            self.maxSubgroup = allPairs.lazy
                .map(\.subgroup)
                .filter { $0 != 0 }
                .max()
        }
    }

    public enum Action: Equatable {
        case day(DayScheduleFeature.Action)
        case continuous(ContinuousScheduleFeature.Action)
        case exams(ExamsScheduleFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.compact, action: /Action.day) {
            DayScheduleFeature()
        }

        Scope(state: \.continuous, action: /Action.continuous) {
            ContinuousScheduleFeature()
        }

        Scope(state: \.exams, action: /Action.exams) {
            ExamsScheduleFeature()
        }
    }
}

// MARK: - Filter

extension LoadedScheduleReducer.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        compact.filter(keepingSubgroup: subgroup)
        continuous.filter(keepingSubgroup: subgroup)
        exams.filter(keepingSubgroup: subgroup)
    }
}
