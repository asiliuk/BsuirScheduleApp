import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PremiumClubFeatureView: View {
    let store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            ForEach(0..<10) { _ in
                Color.random
                    .frame(height: 100)
                    .padding()
            }
        }
        #if DEBUG
        .safeAreaInset(edge: .top) {
            VStack(alignment: .leading) {
                DebugPremiumClubRowView(
                    store: store.scope(
                        state: \.debugRow,
                        action: PremiumClubFeature.Action.debugRow
                    )
                )

                WithViewStore(store, observe: \.source) { viewStore in
                    let source = Text("\(viewStore.state.map(String.init(describing:)) ?? "No source")").bold()
                    Text("Source: \(source)")
                }
            }
            .padding(.horizontal)
            .background(.thickMaterial)
        }
        #endif
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
