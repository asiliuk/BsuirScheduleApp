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
        ContentUnavailableView {
            Label {
                Text("view.errorState.parsing.title", bundle: .module)
            } icon: {
                AnimatableImage(systemName: "ellipsis.curlybraces")
            }
        } description: {
            Text("view.errorState.parsing.message", bundle: .module)
        } actions: {
            Button {
                store.send(.openIssueTapped)
            } label: {
                Label {
                    Text("view.errorState.parsing.button.label", bundle: .module)
                } icon: {
                    Image(systemName: "plus.diamond.fill")
                }
            }
            .buttonStyle(.borderedProminent)
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
