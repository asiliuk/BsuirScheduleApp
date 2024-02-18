import Foundation
import BsuirApi
import ComposableArchitecture

@Reducer
public struct GroupsSearch {
    @ObservableState
    public struct State: Equatable {
        var tokens: [StrudentGroupSearchToken] = []
        var suggestedTokens: [StrudentGroupSearchToken] = []
        var query: String = ""
        fileprivate(set) var dismiss: Int = 0

        @discardableResult
        mutating func reset() -> Bool {
            guard !query.isEmpty else { return false }
            dismiss += 1
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
            .onChange(of: \.query) { _, query in
                if query.isEmpty {
                    Reduce { state, _ in
                        state.dismiss += 1
                        return .none
                    }
                }
            }
            .onChange(of: \.tokens) { _, _ in
                Reduce { _, _ in
                    .send(.delegate(.didUpdateImportantState))
                }
            }

        Reduce { state, action in
            switch action {
            case .filter:
                return .send(.delegate(.didUpdateImportantState))

            case .binding, .delegate:
                return .none
            }
        }
    }
}
