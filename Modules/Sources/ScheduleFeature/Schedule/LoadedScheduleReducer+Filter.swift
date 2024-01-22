import Foundation

extension LoadedScheduleReducer.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        compact.filter(keepingSubgroup: subgroup)
        continuous.filter(keepingSubgroup: subgroup)
        exams.filter(keepingSubgroup: subgroup)
    }
}
