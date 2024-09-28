import Foundation
import WhatsNewKit
import ComposableArchitecture

@Reducer
public struct WhatsNewFeature {
    @ObservableState
    public struct State: Equatable {
        var whatsNew: WhatsNew
    }
}

// MARK: - Equatable

extension WhatsNew: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.version == rhs.version
            && lhs.title == rhs.title
            && lhs.features == rhs.features
    }
}
