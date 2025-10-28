import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

@Reducer
public struct PairFormIcons {
    @ObservableState
    public struct State {
        @Shared(.alwaysShowFormIcon) var alwaysShowIcon
        var pairForms: IdentifiedArrayOf<PairViewForm>

        public init() {
            pairForms = IdentifiedArray(uncheckedUniqueElements: PairViewForm.allCases)
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
}
