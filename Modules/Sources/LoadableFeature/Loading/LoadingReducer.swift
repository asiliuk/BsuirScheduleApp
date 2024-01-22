import Foundation
import ComposableArchitecture

extension Reducer where Action: LoadableAction, Action.State == State {
    public func load<Value: Equatable>(
        _ keyPath: WritableKeyPath<State, LoadableState<Value>>,
        fetch: @Sendable @escaping (State, _ isRefresh: Bool) async throws -> Value
    ) -> some Reducer<State, Action> {
        CombineReducers {
            LoadingReducer(keyPath: keyPath, fetch: fetch)
            self
        }
    }
    
    public func load<ValueState: Equatable, ValueAction>(
        _ keyPath: WritableKeyPath<State, LoadableState<ValueState>>,
        action: AnyCasePath<Action, ValueAction>,
        @ReducerBuilder<ValueState, ValueAction> _ valueReducer: () -> some Reducer<ValueState, ValueAction>,
        fetch: @Sendable @escaping (State, _ isRefresh: Bool) async throws -> ValueState
    ) -> some Reducer<State, Action> {
        load(keyPath, fetch: fetch)
            .ifLet(
                keyPath.appending(path: \.wrappedValue),
                action: action,
                then: valueReducer
            )
    }
}

// MARK: - LoadingReducer

@Reducer
struct LoadingReducer<State, Action, Value: Equatable> where Action: LoadableAction, State == Action.State {

    let keyPath: WritableKeyPath<State, LoadableState<Value>>
    let fetch: @Sendable (State, _ isRefresh: Bool) async throws -> Value

    var body: some Reducer<State, Action> {
        Scope(state: keyPath, action: .loading(keyPath: keyPath)) {
            Scope(state: /LoadableState.error, action: /LoadingAction<State>.Action.loadingError) {
                LoadingError()
            }
        }

        Scope(state: \.self, action: .loading(keyPath: keyPath)) {
            CoreLoadingReducer(keyPath: keyPath, fetch: fetch)
        }
    }
}

@Reducer
private struct CoreLoadingReducer<State, Value: Equatable> {

    typealias Action = LoadingAction<State>.Action

    let keyPath: WritableKeyPath<State, LoadableState<Value>>
    let fetch: @Sendable (State, _ isRefresh: Bool) async throws -> Value

    @Dependency(\.continuousClock) var clock

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        var valueState: LoadableState<Value> {
            get { state[keyPath: keyPath] }
            set { state[keyPath: keyPath] = newValue }
        }

        switch action {
        case .onAppear where valueState.isInitial:
            valueState = .loading
            return .merge(
                load(state, isRefresh: false),
                loadingStarted()
            )

        case .loadingError(.reload) where valueState.isError:
            valueState = .loading
            return .merge(
                load(state, isRefresh: true),
                loadingStarted()
            )

        case .refresh where valueState.isError || valueState.isSome:
            return load(state, isRefresh: true)

        case let ._loaded(value, _):
            valueState = .some(value as! Value)
            return loadingFinished()

        case let ._loadingFailed(error):
            valueState = .error(.init(error))
            return loadingFinished()
            
        case .delegate, .loadingError, .onAppear, .refresh:
            return .none
        }
    }

    private func loadingStarted() -> Effect<Action> {
        return .send(.delegate(.loadingStarted))
    }

    private func loadingFinished() -> Effect<Action> {
        return .send(.delegate(.loadingFinished))
    }

    private func load(_ state: State, isRefresh: Bool) -> Effect<Action> {
        return .run { send in
            if isRefresh {
                try await clock.sleep(for: .milliseconds(200))
            }

            let value = try await fetch(state, isRefresh)
            await send(._loaded(value, isEqualTo: { $0 as? Value == value }))
        } catch: { error, send in
            await send(._loadingFailed(error))
        }
        .animation()
        .cancellable(id: CancelID.loading, cancelInFlight: true)
    }

    private enum CancelID {
        case loading
    }
}

// MARK: - CasePath

private extension AnyCasePath {
    static func loading<V>(
        keyPath: WritableKeyPath<Root.State, LoadableState<V>>
    ) -> AnyCasePath where Root: LoadableAction, Value == LoadingAction<Root.State>.Action {
        AnyCasePath(
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
