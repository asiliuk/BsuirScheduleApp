import Foundation
import SwiftUI

enum PairFilteringMode {
    case filter
    case keepingSubgroup(Int)
    case noFiltering
}

extension EnvironmentValues {
    @Entry var pairFilteringMode: PairFilteringMode = .noFiltering
}
