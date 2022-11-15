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
    
    public init<State, Action: LoadableAction, LoadingValueState>(
        _ store: Store<State, Action>,
        state keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        loading loadingKeyPath: WritableKeyPath<State, LoadableState<LoadingValueState>>,
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
            let wrapping = { Action.loading(.init(keyPath: loadingKeyPath, action: .view($0))) }
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
                loading
                    .task { await ViewStore(store).send(.task).finish() }
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

// MARK: - Inits

// To make compiler happy
// if loading key path is optional with default nil then
// compiler can't digure out trailing closure syntax
extension LoadingStore {
    public init<State, Action: LoadableAction>(
        _ store: Store<State, Action>,
        state keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        @ViewBuilder value: @escaping (Store<ValueState, ViewAction.LoadedAction>) -> ValueView,
        @ViewBuilder loading: () -> LoadingView,
        @ViewBuilder error: @escaping (Store<Void, ViewAction.ErrorAction>) -> ErrorView
    ) where Action.State == State, ValueAction == Never {
        self.init(
            store,
            state: keyPath,
            loading: keyPath,
            value: value,
            loading: loading,
            error: error
        )
    }
    
    public init<State, Action: LoadableAction>(
        _ store: Store<State, Action>,
        state keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        action fromValueAction: @escaping (ValueAction) -> Action,
        @ViewBuilder value: @escaping (Store<ValueState, ViewAction.LoadedAction>) -> ValueView,
        @ViewBuilder loading: () -> LoadingView,
        @ViewBuilder error: @escaping (Store<Void, ViewAction.ErrorAction>) -> ErrorView
    ) where Action.State == State {
        self.init(
            store,
            state: keyPath,
            loading: keyPath,
            action: fromValueAction,
            value: value,
            loading: loading,
            error: error
        )
    }
    
    public init<State, Action: LoadableAction, LoadingValueState>(
        _ store: Store<State, Action>,
        state keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        loading loadingKeyPath: WritableKeyPath<State, LoadableState<LoadingValueState>>,
        @ViewBuilder value: @escaping (Store<ValueState, ViewAction.LoadedAction>) -> ValueView,
        @ViewBuilder loading: () -> LoadingView,
        @ViewBuilder error: @escaping (Store<Void, ViewAction.ErrorAction>) -> ErrorView
    ) where Action.State == State, ValueAction == Never {
        func impossible<T>(_: Never) -> T {}
        
        self.init(
            store,
            state: keyPath,
            loading: loadingKeyPath,
            action: impossible,
            value: value,
            loading: loading,
            error: error
        )
    }
}

// MARK: - Store + Helpers

public typealias LoadedStoreOf<Reducer: ReducerProtocol> = Store<Reducer.State, LoadingStoreViewAction<Reducer.Action>.LoadedAction>

extension Store {
    public func loaded<ValueAction>() -> Store<State, ValueAction> where Action == LoadingStoreViewAction<ValueAction>.LoadedAction {
        loaded(state: { $0 })
    }
    
    public func loaded<ChildState, ValueAction>(
        state: @escaping (State) -> ChildState
    ) -> Store<ChildState, ValueAction>
    where Action == LoadingStoreViewAction<ValueAction>.LoadedAction {
        scope(state: state, action: { .value($0) })
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
