import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct PremiumClubContentView: View {
    let store: StoreOf<PremiumClubFeature>

    var body: some View {
        ScrollView {

        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {} label: { Text("Buy premium pass").frame(maxWidth: .infinity) }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)

                Button("Restore purchase") {}
            }
            .padding(.horizontal)
        }
        .navigationTitle("Premium Club")
    }
}

struct PremiumClubContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PremiumClubContentView(
                store: .init(
                    initialState: .init(),
                    reducer: PremiumClubFeature()
                )
            )
        }
    }
}
