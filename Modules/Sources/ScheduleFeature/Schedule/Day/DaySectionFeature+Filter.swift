import Foundation

extension DaySectionFeature.State {
    mutating func filter(keepingSubgroup: Int?) {
        func isFiltered(subgroup: Int) -> Bool {
            if relativity == .past { return true }
            guard let keepingSubgroup, subgroup > 0 else { return false }
            return subgroup != keepingSubgroup
        }

        for index in pairRows.indices {
            pairRows[index].isFiltered = isFiltered(subgroup: pairRows[index].pair.subgroup)
        }

        self.keepingSubgroup = keepingSubgroup
    }
}
