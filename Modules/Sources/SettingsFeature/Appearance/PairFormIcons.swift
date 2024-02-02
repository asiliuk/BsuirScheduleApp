import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

@Reducer
public struct PairFormIcons {
    @ObservableState
    public struct State: Equatable {
        var alwaysShowIcon: Bool
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
            .onChange(of: \.alwaysShowIcon) { _, newValue in
                Reduce { _, _ in
                    pairFormDisplayService.alwaysShowFormIcon = newValue
                    return .none
                }
            }
    }
}
