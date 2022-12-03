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
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 24) {
                Spacer()

                Group {
                    if #available(iOS 16.0, *) {
                        AnimatableImage(systemName: "ellipsis.curlybraces")
                    } else {
                        Image(systemName: "ellipsis.curlybraces")
                    }
                }
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
                        address: viewStore.address,
                        message: viewStore.message
                    )
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)

                Button {
                    viewStore.send(.openIssueTapped)
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
        LoadingErrorFailedToDecodeView(
            store: Store(
                initialState: .init(
                    url: URL(string: "https://bsuir.api.by/some/path/for/something"),
                    description: "This is test message\n from backend...\n maybe with formatting"
                ),
                reducer: EmptyReducer()
            )
        )
    }
}
