import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorNotConnectedToInternetView: View, Animatable {
    public let store: StoreOf<LoadingErrorNotConnectedToInternet>

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text("view.errorState.noInternet.title", bundle: .module)
            } icon: {
                AnimatableImage(systemName: "wifi.router.fill")
            }
        } description: {
            Text("view.errorState.noInternet.message", bundle: .module)
        } actions: {
            Button {
                store.send(.reloadButtonTapped)
            } label: {
                Label {
                    Text("view.errorState.noInternet.button.label", bundle: .module)
                } icon: {
                    Image(systemName: "repeat")
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct LoadingErrorNotConnectedToInternetView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingErrorNotConnectedToInternetView(
            store: Store(initialState: .init()) {}
        )
    }
}
