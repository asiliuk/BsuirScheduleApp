import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorView: View {
    public let store: StoreOf<LoadingError>

    public init(store: StoreOf<LoadingError>) {
        self.store = store
    }

    public var body: some View {
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

#Preview("Unknown") {
    LoadingErrorUnknownView(
        store: .init(
            initialState: .init(),
            reducer: {}
        )
    )
}

#Preview("Not connected") {
    LoadingErrorNotConnectedToInternetView(
        store: .init(
            initialState: .init(),
            reducer: {}
        )
    )
}

#Preview("Failed to decode") {
    LoadingErrorFailedToDecodeView(
        store: .init(
            initialState: .init(
                url: URL(string: "https://iis.bsuir.by/something/something"),
                description: "Failed to decode this shit"
            ),
            reducer: {}
        )
    )
}

#Preview("No schedule") {
    LoadingErrorNoScheduleView(
        store: .init(
            initialState: .init(),
            reducer: {}
        )
    )
}

#Preview("Something went wrong") {
    LoadingErrorSomethingWrongWithBsuirView(
        store: .init(
            initialState: .init(
                url: URL(string: "https://iis.bsuir.by/something/something"),
                description: "This is error message",
                statusCode: 500
            ),
            reducer: {}
        )
    )
}
