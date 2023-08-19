import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

public struct PairFormIcons: Reducer {
    public struct State: Equatable {
        @BindingState var alwaysShowIcon: Bool
        var pairForms: IdentifiedArrayOf<PairViewForm>

        public init() {
            pairForms = IdentifiedArray(uncheckedUniqueElements: PairViewForm.allCases)
            @Dependency(\.pairFormDisplayService) var pairFormDisplayService
            alwaysShowIcon = pairFormDisplayService.alwaysShowFormIcon
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }

    @Dependency(\.pairFormDisplayService) var pairFormDisplayService

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$alwaysShowIcon):
                pairFormDisplayService.alwaysShowFormIcon = state.alwaysShowIcon
                return .none
            case .binding:
                return .none
            }
        }
    }
}
