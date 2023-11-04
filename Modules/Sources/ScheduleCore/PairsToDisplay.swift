import Foundation

public struct PairsToDisplay {
    public let passedInvisible: ArraySlice<PairViewModel>
    public let visible: ArraySlice<PairViewModel>
    public let upcomingInvisible: ArraySlice<PairViewModel>
}

extension PairsToDisplay {
    public init(
        passed: [PairViewModel],
        upcoming: [PairViewModel],
        maxVisibleCount: Int
    ) {
        let passedVisibleCount = maxVisibleCount - upcoming.count
        guard passedVisibleCount > 0 else {
            let splitIndex = upcoming.index(upcoming.startIndex, offsetBy: maxVisibleCount, boundedBy: upcoming.endIndex)
            self.init(
                passedInvisible: passed[...],
                visible: upcoming[..<splitIndex],
                upcomingInvisible: upcoming[splitIndex...]
            )
            return
        }
        
        let splitIndex = passed.index(passed.endIndex, offsetBy: -passedVisibleCount, boundedBy: passed.startIndex)
        self.init(
            passedInvisible: passed[..<splitIndex],
            visible: passed[splitIndex...] + upcoming,
            upcomingInvisible: []
        )
    }
}

extension Array {
    public func index(_ index: Index, offsetBy offset: Int, boundedBy bound: Index) -> Index {
        self.index(index, offsetBy: offset, limitedBy: bound) ?? bound
    }
}
