import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorView: View {
    public let store: StoreOf<LoadingError>

    public init(store: StoreOf<LoadingError>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .unknown:
                CaseLet(
                    /LoadingError.State.unknown,
                     action: LoadingError.Action.unknown
                ) { store in
                    LoadingErrorUnknownView(store: store)
                }

            case .notConnectedToInternet:
                CaseLet(
                    /LoadingError.State.notConnectedToInternet,
                     action: LoadingError.Action.notConnectedToInternet
                ) { store in
                    LoadingErrorNotConnectedToInternetView(store: store)
                }

            case .failedToDecode:
                CaseLet(
                    /LoadingError.State.failedToDecode,
                     action: LoadingError.Action.failedToDecode
                ) { store in
                    LoadingErrorFailedToDecodeView(store: store)
                }

            case .somethingWrongWithBsuir:
                CaseLet(
                    /LoadingError.State.somethingWrongWithBsuir,
                     action: LoadingError.Action.somethingWrongWithBsuir
                ) { store in
                    LoadingErrorSomethingWrongWithBsuirView(store: store)
                }
            }
        }
    }
}
