import Foundation
import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

public struct LoadableErrorView<ValueAction>: View {
    public let store: Store<LoadingError, LoadingStoreViewAction<ValueAction>.ErrorAction>

    public init(store: Store<LoadingError, LoadingStoreViewAction<ValueAction>.ErrorAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let reload = { _ = viewStore.send(.reload) }

            switch viewStore.state {
            case .notConnectedToInternet:
                NetworkErrorStateView(retry: reload)
            case .parsing, .unknown:
                ErrorStateView(retry: reload)
            }
        }
    }
}
