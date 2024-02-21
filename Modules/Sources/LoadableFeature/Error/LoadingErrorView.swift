import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorView: View {
    public let store: StoreOf<LoadingError>

    public init(store: StoreOf<LoadingError>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            switch store.case {
            case .unknown(let store):
                LoadingErrorUnknownView(store: store)
            case .notConnectedToInternet(let store):
                LoadingErrorNotConnectedToInternetView(store: store)
            case .failedToDecode(let store):
                LoadingErrorFailedToDecodeView(store: store)
            case .noSchedule(let store):
                LoadingErrorNoScheduleView(store: store)
            case .somethingWrongWithBsuir(let store):
                LoadingErrorSomethingWrongWithBsuirView(store: store)
            }
        }
    }
}
