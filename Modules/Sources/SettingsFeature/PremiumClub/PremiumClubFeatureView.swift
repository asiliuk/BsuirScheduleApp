import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct PremiumClubFeatureView: View {
    let store: StoreOf<PremiumClubFeature>

    var body: some View {
        ScrollView {
            ForEach(0..<10) { _ in
                Color.random
                    .frame(height: 100)
                    .padding()
            }
        }
        .safeAreaInset(edge: .bottom) {
                Button {} label: { Text("Buy premium pass").frame(maxWidth: .infinity) }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .padding()
                    .background(.thickMaterial)
        }
        .navigationTitle("Premium Club")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Restore") {}
            }
        }
    }
}

struct PremiumClubFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PremiumClubFeatureView(
                store: .init(
                    initialState: .init(),
                    reducer: PremiumClubFeature()
                )
            )
        }
    }
}
