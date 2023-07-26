import SwiftUI
import ComposableArchitecture

struct SubscriptionFooterView: View {
    let store: StoreOf<SubscriptionFooter>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.buttonTapped)
            } label: {
                if let offer = viewStore.offer {
                    VStack {
                        Text("Buy premium pass")
                            .font(.subheadline)
                        Text(offer)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .progressViewStyle(.circular)
                }
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .disabled(!viewStore.isEnabled)
            .task { await viewStore.send(.task).finish() }
        }
    }
}
