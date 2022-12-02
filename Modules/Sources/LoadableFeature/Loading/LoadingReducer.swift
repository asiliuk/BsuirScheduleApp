import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

extension ReducerProtocol where Action: LoadableAction, Action.State == State {
    public func load<Value: Equatable>(
        _ keyPath: WritableKeyPath<State, LoadableState<Value>>,
        fetch: @Sendable @escaping (State, _ isRefresh: Bool) async throws -> Value
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
        fetch: @Sendable @escaping (State, _ isRefresh: Bool) async throws -> ValueState
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
    let fetch: @Sendable (State, _ isRefresh: Bool) async throws -> Value

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.self, action: .loading(keyPath: keyPath)) {
            CoreLoadingReducer(keyPath: keyPath, fetch: fetch)

            Scope(state: keyPath, action: /LoadingAction<State>.Action.view) {
                EmptyReducer()
                    .ifCaseLet(/LoadableState.error, action: /LoadingAction<State>.Action.ViewAction.loadingError) {
                        LoadingError()
                    }
            }
        }
    }
}

private struct CoreLoadingReducer<State, Value: Equatable>: ReducerProtocol {

    typealias Action = LoadingAction<State>.Action

    let keyPath: WritableKeyPath<State, LoadableState<Value>>
    let fetch: @Sendable (State, _ isRefresh: Bool) async throws -> Value

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        var valueState: LoadableState<Value> {
            get { state[keyPath: keyPath] }
            set { state[keyPath: keyPath] = newValue }
        }

        switch action {
        case .view(.onAppear):
            switch valueState {
            case .initial:
                valueState = .loading
                return load(state, isRefresh: false)
            case .loading, .error, .some:
                return .none
            }

        case .view(.loadingError(.reload)):
            switch valueState {
            case .error:
                valueState = .loading
                return load(state, isRefresh: true)
            case .initial, .loading, .some:
                return .none
            }

        case .view(.refresh):
            switch valueState {
            case .error, .some:
                return load(state, isRefresh: true)
            case .loading, .initial:
                return .none
            }

        case let .reducer(.loaded(value, _)):
            valueState = .some(value as! Value)
            return loadingFinished()

        case let .reducer(.loadingFailed(error)):
            valueState = .error(.init(error))
            return loadingFinished()
            
        case .delegate, .view(.loadingError):
            return .none
        }
    }
    
    private func loadingFinished() -> EffectTask<Action> {
        return EffectTask.task { .delegate(.loadingFinished) }
    }

    private enum LoadingCancelId {}

    private func load(_ state: State, isRefresh: Bool) -> EffectTask<Action> {
        return EffectTask.task {
                let value = try await fetch(state, isRefresh)
                return .reducer(.loaded(value, isEqualTo: { $0 as? Value == value }))
            } catch: { error in
                .reducer(.loadingFailed(error))
            }
            .cancellable(id: LoadingCancelId.self, cancelInFlight: true)
    }
}

// MARK: - CasePath

private extension CasePath {
    static func loading<V>(
        keyPath: WritableKeyPath<Root.State, LoadableState<V>>
    ) -> CasePath where Root: LoadableAction, Value == LoadingAction<Root.State>.Action {
        CasePath(
            embed: { loadingAction in
                .loading(.init(keyPath: keyPath, action: loadingAction))
            },
            extract: { action in
                guard
                    let loadingAction = (/Root.loading).extract(from: action),
                    loadingAction.keyPath == keyPath
                else { return nil }

                return loadingAction.action
            }
        )
    }
}
