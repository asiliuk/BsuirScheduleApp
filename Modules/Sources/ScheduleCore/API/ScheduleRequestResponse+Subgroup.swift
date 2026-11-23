import Foundation
import Algorithms
import BsuirApi

extension ScheduleRequestResponse {
    /// Finds max subgroup value across all pairs. Returns `nil` if no pair split by subgroup exist.
    public var maxSubgroup: Int? {
        let allSchedulePairs = DaySchedule.WeekDay.allCases
            .lazy
            .compactMap { schedule[$0] }
            .flatMap { $0 }

        let allPairs = chain(allSchedulePairs, exams)

        return allPairs.lazy
            .map(\.subgroup)
            .filter { $0 != 0 }
            .max()
    }
}
