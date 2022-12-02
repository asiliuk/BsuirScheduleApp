import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorNotConnectedToInternetView: View, Animatable {
    public let store: StoreOf<LoadingErrorNotConnectedToInternet>

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Group {
                if #available(iOS 16.0, *) {
                    AnimatableImage(systemName: "wifi.router.fill")
                } else {
                    Image(systemName: "wifi.router.fill")
                }
            }
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
                ViewStore(store.stateless).send(.reloadButtonTapped)
            } label: {
                Image(systemName: "repeat")
                Text("view.errorState.noInternet.button.label")
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
}

@available(iOS 16.0, *)
struct AnimatableImage: View {
    private struct _Image: View, Animatable {
        let systemName: String
        var variableValue: Double

        var animatableData: Double {
            get { variableValue }
            set { variableValue = newValue }
        }

        var body: some View {
            Image(systemName: systemName, variableValue: min(max(variableValue, 0), 1))
        }
    }

    let systemName: String
    @State var variableValue: Double = -0.1

    var body: some View {
        _Image(systemName: systemName, variableValue: variableValue)
            .onAppear {
                withAnimation(.default.speed(0.3).repeatForever(autoreverses: true)) {
                    variableValue = 1
                }
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
