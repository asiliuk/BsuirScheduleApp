import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

extension ReducerProtocol where Action: LoadableAction, Action.State == State {
    public func load<Value: Equatable>(
        _ keyPath: WritableKeyPath<State, LoadableState<Value>>,
        fetch: @escaping (State) -> EffectTask<TaskResult<Value>>
    ) -> some ReducerProtocol<State, Action> {
        CombineReducers {
            LoadingReducer(keyPath: keyPath, fetch: fetch)
            self
        }
    }
    
    public func load<ValueState: Equatable, ValueAction>(
        _ keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        action: CasePath<Action, ValueAction>,
        @ReducerBuilder<ValueState, ValueAction> _ valueReducer: () -> some ReducerProtocol<ValueState, ValueAction>,
        fetch: @escaping (State) -> EffectTask<TaskResult<ValueState>>
    ) -> some ReducerProtocol<State, Action> {
        load(keyPath, fetch: fetch)
            .ifLet(
                keyPath.appending(path: \.wrappedValue),
                action: action,
                then: valueReducer
            )
    }
}

// MARK: - LoadingReducer

struct LoadingReducer<State, Action, Value: Equatable>: ReducerProtocol
where Action: LoadableAction, State == Action.State {

    let keyPath: WritableKeyPath<State, LoadableState<Value>>
    let fetch: (State) -> EffectTask<TaskResult<Value>>

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        guard
            let loadingAction = (/Action.loading).extract(from: action),
            loadingAction.keyPath == keyPath
        else { return .none }

        var valueState: LoadableState<Value> {
            get { state[keyPath: keyPath] }
            set { state[keyPath: keyPath] = newValue }
        }
        
        switch loadingAction.action {
        case .view(.onAppear), .view(.reload):
            switch valueState {
            case .initial, .error:
                valueState = .loading
                return load(state)
            case .loading, .some:
                return .none
            }

        case .view(.refresh):
            switch valueState {
            case .error, .some:
                return load(state)
            case .loading, .initial:
                return .none
            }

        case let .reducer(.loaded(value, _)):
            valueState = .some(value as! Value)
            return loadingFinished()

        case .reducer(.loadingFailed):
            valueState = .error
            return loadingFinished()
            
        case .delegate:
            return .none
        }
    }
    
    private func loadingFinished() -> EffectTask<Action> {
        return EffectTask.task { .delegate(.loadingFinished) }
            .map(toLoadingAction)
    }

    private enum LoadingCancelId {}

    private func load(_ state: State) -> EffectTask<Action> {
        return fetch(state)
            .map { result in
                switch result {
                case let .success(value):
                    return .reducer(.loaded(value, isEqualTo: { $0 as? Value == value }))
                case .failure:
                    return .reducer(.loadingFailed)
                }
            }
            .map(toLoadingAction)
            .cancellable(id: LoadingCancelId.self, cancelInFlight: true)
    }
    
    private func toLoadingAction(_ action: LoadingAction<State>.Action) -> Action {
        return .loading(.init(keyPath: keyPath, action: action))
    }
}
