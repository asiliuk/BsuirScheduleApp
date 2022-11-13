import Foundation
import ComposableArchitecture
import SwiftUI

public struct LoadingStore<
    ValueState: Equatable,
    ValueAction,
    ValueView: View,
    LoadingView: View,
    ErrorView: View
>: View {

    private enum ViewState: Equatable {
        case loading
        case error
        case loaded(ValueState)
    }
    
    public typealias ViewAction = LoadingStoreViewAction<ValueAction>
    
    private let store: Store<ViewState, ViewAction>
    @ViewBuilder private var value: (Store<ValueState, ViewAction.LoadedAction>) -> ValueView
    @ViewBuilder private var loading: LoadingView
    @ViewBuilder private var error: (Store<Void, ViewAction.ErrorAction>) -> ErrorView
    
    public init<State, Action: LoadableAction>(
        _ store: Store<State, Action>,
        loading keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        @ViewBuilder value: @escaping (Store<ValueState, ViewAction.LoadedAction>) -> ValueView,
        @ViewBuilder loading: () -> LoadingView,
        @ViewBuilder error: @escaping (Store<Void, ViewAction.ErrorAction>) -> ErrorView
    ) where Action.State == State, ValueAction == Never {
        func impossible<T>(_: Never) -> T {}
        
        self.init(
            store,
            loading: keyPath,
            action: impossible,
            value: value,
            loading: loading,
            error: error
        )
    }
    
    public init<State, Action: LoadableAction>(
        _ store: Store<State, Action>,
        loading keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        action fromValueAction: @escaping (ValueAction) -> Action,
        @ViewBuilder value: @escaping (Store<ValueState, ViewAction.LoadedAction>) -> ValueView,
        @ViewBuilder loading: () -> LoadingView,
        @ViewBuilder error: @escaping (Store<Void, ViewAction.ErrorAction>) -> ErrorView
    ) where Action.State == State {
        func toViewState(_ state: State) -> ViewState {
            switch state[keyPath: keyPath] {
            case .initial, .loading:
                return .loading
            case .error:
                return .error
            case let .some(value):
                return .loaded(value)
            }
        }
        
        func fromViewAction(_ viewAction: ViewAction) -> Action {
            let wrapping = { Action.loading(.init(keyPath: keyPath, action: .view($0))) }
            switch viewAction {
            case .loading(.task):
                return wrapping(.task)
            case .error(.reload):
                return wrapping(.reload)
            case .loaded(.refresh):
                return wrapping(.refresh)
            case let .loaded(.value(valueAction)):
                return fromValueAction(valueAction)
            }
        }
        
        self.store = store.scope(state: toViewState, action: fromViewAction)
        self.value = value
        self.loading = loading()
        self.error = error
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /ViewState.loading, action: ViewAction.loading) { store in
                WithViewStore(store) { viewStore in
                    loading
                        .task { await viewStore.send(.task).finish() }
                }
            }
            
            CaseLet(state: /ViewState.error, action: ViewAction.error) { store in
                error(store)
            }

            CaseLet(state: /ViewState.loaded, action: ViewAction.loaded) { store in
                value(store)
            }
        }
    }
}

// MARK: - Store + Helpers

extension Store {
    public func loaded<ValueAction>() -> Store<State, ValueAction> where Action == LoadingStoreViewAction<ValueAction>.LoadedAction {
        scope(state: { $0 }, action: { .value($0) })
    }
}

// MARK: - Action

public enum LoadingStoreViewAction<ValueAction> {
    public enum LoadingAction {
        case task
    }
    
    public enum ErrorAction {
        case reload
    }
    
    public enum LoadedAction {
        case refresh
        case value(ValueAction)
    }

    case loading(LoadingAction)
    case error(ErrorAction)
    case loaded(LoadedAction)
}
