import Foundation
import WhatsNewKit
import ComposableArchitecture

public struct WhatsNewFeature: Reducer {
    public struct State: Equatable {
        var whatsNew: WhatsNew
        var presentedWhatsNew: WhatsNew?

        init?() {
            @Dependency(\.whatsNewService) var whatsNewService
            guard let whatsNew = whatsNewService.whatsNew() else { return nil }
            self.whatsNew = whatsNew
        }
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case whatsNewDismissed
        }

        case whatsNewTapped
        case whatsNewDismissed

        case setPresentedWhatsNew(WhatsNew?)
        case delegate(Delegate)
    }

    @Dependency(\.whatsNewService) var whatsNewService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .whatsNewTapped:
                state.presentedWhatsNew = state.whatsNew
                return .none

            case .whatsNewDismissed:
                print("Dismissed")
                let version = state.whatsNew.version
                return .merge(
                    .run { _ in whatsNewService.markWhatsNewPresented(version: version) },
                    .send(.delegate(.whatsNewDismissed))
                )

            case .setPresentedWhatsNew(let value):
                state.presentedWhatsNew = value
                return .none

            case .delegate:
                return .none
            }
        }
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
