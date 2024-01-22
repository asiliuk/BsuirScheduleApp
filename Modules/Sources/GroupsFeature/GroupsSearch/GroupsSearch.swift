import Foundation
import BsuirApi
import ComposableArchitecture

@Reducer
public struct GroupsSearch {
    public struct State: Equatable {
        @BindingState var tokens: [StrudentGroupSearchToken] = []
        @BindingState var suggestedTokens: [StrudentGroupSearchToken] = []
        @BindingState var query: String = ""
        fileprivate(set) var dismiss: Bool = false

        @discardableResult
        mutating func reset() -> Bool {
            guard !query.isEmpty else { return false }
            dismiss = true
            return true
        }
    }

    public enum Action: Equatable, BindableAction {
        public enum DelegateAction: Equatable {
            case didUpdateImportantState
        }

        case filter
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$query):
                if state.query.isEmpty {
                    state.dismiss = false
                }
                return .none

            case .filter, .binding(\.$tokens):
                return .send(.delegate(.didUpdateImportantState))

            case .binding, .delegate:
                return .none
            }
        }
    }
}
