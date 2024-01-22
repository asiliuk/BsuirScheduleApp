import Foundation

extension ScheduleListFeature.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        days.filter(keepingSubgroup: subgroup)
    }
}

extension MutableCollection where Element == DaySectionFeature.State {
    mutating func filter(keepingSubgroup subgroup: Int?) {
        for index in indices {
            self[index].filter(keepingSubgroup: subgroup)
        }
    }
}
