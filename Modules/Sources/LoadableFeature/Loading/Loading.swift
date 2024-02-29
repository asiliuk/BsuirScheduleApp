import Foundation
import ComposableArchitecture

// MARK: - State

@CasePathable
@ObservableState
public enum LoadingState<State> {
    case initial
    case inProgress
    case failed(LoadingError.State)
    case loaded(State)

    public init() { self = .initial }

    public var failed: LoadingError.State? {
        get { if case .failed(let state) = self { state } else { nil } }
        set {
            guard let newValue else { return }
            self = .failed(newValue)
        }
    }

    public var loaded: State? {
        get { if case .loaded(let state) = self { state } else { nil } }
        set {
            guard let newValue else { return }
            self = .loaded(newValue)
        }
    }
}

extension LoadingState: Equatable where State: Equatable {}

// MARK: - Action

public typealias LoadingActionOf<R: Reducer> = LoadingAction<R.State, R.Action>

@CasePathable
public enum LoadingAction<State, Action> {
    case fetch
    case refresh
    case reload
    case fetchFinished(Result<State, NSError>)
    case failed(LoadingError.Action)
    case loaded(Action)
}

extension LoadingAction: Equatable where State: Equatable, Action: Equatable {}

// MARK: - Reducer

public typealias LoadingStoreOf<R: Reducer> = Store<LoadingState<R.State>, LoadingActionOf<R>>

extension Reducer where Action: CasePathable {
    /// Asynchronously fetch child state and run its logic when succeed or show error logic on failure
    /// - Parameters:
    ///   - state: KeyPath to the child loading state
    ///   - action: CasePath to child loading action
    ///   - fetch: Closure to fetch child state
    ///     - state: The state of the reducer at the moment of fetch start
    ///     - isRefresh: Wether or not this is refresh initiated by user. Meaning cache should be skipped
    /// - Returns: Reducer that incorporates loading logic
    public func load<LoadedState, LoadedAction>(
        state: WritableKeyPath<State, LoadingState<LoadedState>>,
        action: CaseKeyPath<Action, LoadingAction<LoadedState, LoadedAction>>,
        fetch: @escaping (State, Bool) async throws -> LoadedState
    ) -> some Reducer<State, Action> {
        load(
            state: state,
            action: action,
            fetch: fetch,
            loaded: { EmptyReducer() }
        )
    }

    /// Asynchronously fetch child state and run its logic when succeed or show error logic on failure
    /// - Parameters:
    ///   - state: KeyPath to the child loading state
    ///   - action: CasePath to child loading action
    ///   - fetch: Closure to fetch child state
    ///     - state: The state of the reducer at the moment of fetch start
    ///     - isRefresh: Wether or not this is refresh initiated by user. Meaning cache should be skipped
    ///   - loaded: Reducer to run when fetch succeed
    /// - Returns: Reducer that incorporates loading logic
    public func load<LoadedState, LoadedAction>(
        state: WritableKeyPath<State, LoadingState<LoadedState>>,
        action: CaseKeyPath<Action, LoadingAction<LoadedState, LoadedAction>>,
        fetch: @escaping (State, _ isRefresh: Bool) async throws -> LoadedState,
        @ReducerBuilder<LoadedState, LoadedAction> loaded: () -> some Reducer<LoadedState, LoadedAction>
    ) -> some Reducer<State, Action> {
        Loading(
            parent: self,
            loaded: loaded(),
            fetch: fetch,
            toLoadingState: state,
            toLoadingAction: action
        )
    }
}

@Reducer
private struct Loading<Parent: Reducer, Loaded: Reducer> where Parent.Action: CasePathable {
    let parent: Parent
    let loaded: Loaded
    let fetch: (Parent.State, Bool) async throws -> Loaded.State

    let toLoadingState: WritableKeyPath<Parent.State, LoadingState<Loaded.State>>
    let toLoadingAction: CaseKeyPath<Parent.Action, LoadingAction<Loaded.State, Loaded.Action>>

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Parent> {
        // Run fetching logic first
        Reduce { state, action in
            // Extract loading action
            guard let loadingAction = action[case: toLoadingAction] else { return .none }

            var loadingState: LoadingState<Loaded.State> {
                get { state[keyPath: toLoadingState] }
                set { state[keyPath: toLoadingState] = newValue}
            }

            switch loadingAction {
            case .fetch where loadingState.is(\.initial):
                // Start fetching and update state
                loadingState = .inProgress
                return load(state: state, isRefresh: false)

            case .reload where loadingState.is(\.failed):
                // Reload and show full loading animation again
                loadingState = .inProgress
                return load(state: state, isRefresh: true)

            case .failed(let action) where action.isReload && loadingState.is(\.failed):
                // Reload and show full loading animation again
                loadingState = .inProgress
                return load(state: state, isRefresh: true)

            case .refresh where loadingState.is(\.failed) || loadingState.is(\.loaded):
                // Just fetch again without changing loading state
                // this way content would not disappear when pull-to-refresh
                return load(state: state, isRefresh: true)

            case .fetchFinished(let .success(childState)):
                loadingState = .loaded(childState)
                return .none

            case .fetchFinished(let .failure(error)):
                loadingState = .failed(.init(error))
                return .none

            case .fetch, .refresh, .reload, .failed, .loaded:
                return .none
            }
        }

        // Make sure parent runs it's logic after
        parent

        // Run loading logic last
        Scope(state: toLoadingState, action: toLoadingAction) {
            Scope(state: \.failed, action: \.failed) {
                LoadingError.body
            }

            Scope(state: \.loaded, action: \.loaded) {
                loaded
            }
        }
    }

    private func load(state: Parent.State, isRefresh: Bool) -> Effect<Parent.Action> {
        .run { send in
            if isRefresh {
                try await clock.sleep(for: .milliseconds(200))
            }
            let childState = try await fetch(state, isRefresh)
            await send(toLoadingAction(.fetchFinished(.success(childState))))
        } catch: { error, send in
            await send(toLoadingAction(.fetchFinished(.failure(error as NSError))))
        }
        .animation()
        .cancellable(id: CancelID.fetching, cancelInFlight: true)
    }

    private enum CancelID {
        case fetching
    }
}
