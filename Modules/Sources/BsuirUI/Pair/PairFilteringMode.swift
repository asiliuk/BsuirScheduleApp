import Foundation
import SwiftUI
import ScheduleCore

public enum PairFilteringMode {
    case filter
    case keepingSubgroup(Int)
    case noFiltering
}

extension EnvironmentValues {
    @Entry public var pairFilteringMode: PairFilteringMode = .noFiltering
}

extension PairViewModel {
    public func matches(filteringMode: PairFilteringMode) -> Bool {
        switch filteringMode {
        case .keepingSubgroup(subgroup), .filter: true
        case .keepingSubgroup where subgroup == 0: false
        case .keepingSubgroup, .noFiltering: false
        }
    }
}
