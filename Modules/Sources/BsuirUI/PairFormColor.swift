import Foundation
import SwiftUI

public enum PairFormColor: String, CaseIterable {
    case red
    case pink
    case orange
    case yellow
    case green
    case cyan
    case blue
    case indigo
    case purple
    case gray
    case brown
}

extension PairFormColor {
    public var color: Color {
        switch self {
        case .red: return .red
        case .pink: return .pink
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .cyan: return .cyan
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .gray: return .gray
        case .brown: return .brown
        }
    }
}

extension PairFormColor {
    public var name: LocalizedStringKey {
        LocalizedStringKey(stringLiteral: "color.\(rawValue)")
    }
}
