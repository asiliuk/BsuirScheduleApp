import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorNotConnectedToInternetView: View, Animatable {
    public let store: StoreOf<LoadingErrorNotConnectedToInternet>

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            AnimatableImage(systemName: "wifi.router.fill")
                .font(.system(size: 70))

            VStack(spacing: 12) {
                Text("view.errorState.noInternet.title")
                    .font(.title2)
                    .bold()

                Text("view.errorState.noInternet.message")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .multilineTextAlignment(.center)

            Button {
                store.send(.reloadButtonTapped)
            } label: {
                Image(systemName: "repeat")
                Text("view.errorState.noInternet.button.label")
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
}

struct LoadingErrorNotConnectedToInternetView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingErrorNotConnectedToInternetView(
            store: Store(initialState: (), reducer: EmptyReducer())
        )
    }
}
