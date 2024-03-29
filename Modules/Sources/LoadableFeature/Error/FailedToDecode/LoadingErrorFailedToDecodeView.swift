import Foundation
import BsuirCore
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorFailedToDecodeView: View, Animatable {
    public let store: StoreOf<LoadingErrorFailedToDecode>

    public init(store: StoreOf<LoadingErrorFailedToDecode>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 24) {
                Spacer()

                AnimatableImage(systemName: "ellipsis.curlybraces")
                    .font(.system(size: 70))

                VStack(spacing: 12) {
                    Text("view.errorState.parsing.title")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("view.errorState.parsing.message")
                        .font(.body)
                        .foregroundColor(.secondary)

                    NetworkErrorMessageField(
                        address: store.address,
                        message: store.message
                    )
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)

                Button {
                    store.send(.openIssueTapped)
                } label: {
                    Label("view.errorState.parsing.button.label", systemImage: "plus.diamond.fill")
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
        }
    }
}

struct LoadingErrorFailedToDecodeView_Previews: PreviewProvider {
    static var previews: some View {
        let initialState = LoadingErrorFailedToDecode.State(
            url: URL(string: "https://bsuir.api.by/some/path/for/something"),
            description: "This is test message\n from backend...\n maybe with formatting"
        )

        LoadingErrorFailedToDecodeView(
            store: Store(initialState: initialState) {}
        )
    }
}
