import SwiftUI
import ComposableArchitecture

public struct LoadingView<
    LoadedState,
    LoadedAction,
    InProgressView: View,
    FailedView: View,
    LoadedView: View
>: View {
    private let store: Store<LoadingState<LoadedState>, LoadingAction<LoadedState, LoadedAction>>

    private let inProgress: () -> InProgressView
    private let failed: (StoreOf<LoadingError>, _ reload: @escaping () -> Void) -> FailedView
    private let loaded: (Store<LoadedState, LoadedAction>, _ refresh: @escaping () async -> Void) -> LoadedView

    public init(
        store: Store<LoadingState<LoadedState>, LoadingAction<LoadedState, LoadedAction>>,
    @ViewBuilder inProgress: @escaping () -> InProgressView,
    @ViewBuilder failed: @escaping (StoreOf<LoadingError>, _ reload: @escaping () -> Void) -> FailedView,
    @ViewBuilder loaded: @escaping (Store<LoadedState, LoadedAction>, _ refresh: @escaping () async -> Void) -> LoadedView
    ) {
        self.store = store
        self.inProgress = inProgress
        self.failed = failed
        self.loaded = loaded
    }

    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                switch store.state {
                case .initial, .inProgress:
                    inProgress()
                        .onAppear { store.send(.fetch) }
                case .failed:
                    if let failedStore = store.scope(state: \.failed, action: \.failed) {
                        failed(failedStore, { store.send(.reload) })
                    }
                case .loaded:
                    if let loadedStore = store.scope(state: \.loaded, action: \.loaded) {
                        loaded(loadedStore, { await store.send(.refresh).finish() })
                    }
                }
            }
        }
    }
}
