import Foundation
import WhatsNewKit
import ComposableArchitecture

@Reducer
public struct WhatsNewFeature {
    @ObservableState
    public struct State: Equatable {
        var whatsNew: WhatsNew
        var presentedWhatsNew: WhatsNew?

        init?() {
            @Dependency(\.whatsNewService) var whatsNewService
            guard let whatsNew = whatsNewService.whatsNew() else { return nil }
            self.whatsNew = whatsNew
        }
    }

    public enum Action: Equatable, BindableAction {
        public enum Delegate: Equatable {
            case whatsNewDismissed
        }

        case whatsNewTapped
        case whatsNewDismissed

        case delegate(Delegate)
        case binding(BindingAction<State>)
    }

    @Dependency(\.whatsNewService) var whatsNewService

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .whatsNewTapped:
                state.presentedWhatsNew = state.whatsNew
                return .none

            case .whatsNewDismissed:
                let version = state.whatsNew.version
                return .merge(
                    .run { _ in whatsNewService.markWhatsNewPresented(version: version) },
                    .send(.delegate(.whatsNewDismissed))
                )

            case .delegate, .binding:
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
