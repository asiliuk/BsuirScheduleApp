import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorView: View {
    public let store: StoreOf<LoadingError>

    public init(store: StoreOf<LoadingError>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /LoadingError.State.unknown, action: LoadingError.Action.unknown) { store in
                LoadingErrorUnknownView(store: store)
            }

            CaseLet(state: /LoadingError.State.notConnectedToInternet, action: LoadingError.Action.notConnectedToInternet) { store in
                LoadingErrorNotConnectedToInternetView(store: store)
            }

            CaseLet(state: /LoadingError.State.failedToDecode, action: LoadingError.Action.failedToDecode) { store in
                LoadingErrorFailedToDecodeView(store: store)
            }

            CaseLet(state: /LoadingError.State.somethingWrongWithBsuir, action: LoadingError.Action.somethingWrongWithBsuir) { store in
                Color.red
            }
        }
    }
}
