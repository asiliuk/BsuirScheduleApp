import SwiftUI
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PremiumClubFeatureView: View {
    let store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox {
                    Color.clear
                        .frame(height: 100)
                } label: {
                    Label("Custom App Icons", systemImage: "app.gift.fill")
                        .settingsRowAccent(.orange)
                }

                GroupBox {
                    Color.clear
                        .frame(height: 100)
                } label: {
                    Label("Pinned Schedule", systemImage: "pin.square.fill")
                        .settingsRowAccent(.red)
                }

                GroupBox {
                    Color.clear
                        .frame(height: 100)
                } label: {
                    Label("Widgets", systemImage: "square.text.square.fill")
                        .settingsRowAccent(.blue)
                }

                GroupBox {
                    Color.clear
                        .frame(height: 100)
                } label: {
                    Label("No Fake Ads", systemImage: "hand.raised.square.fill")
                        .settingsRowAccent(.purple)
                }

                GroupBox {
                    VStack(alignment: .leading) {
                        LabeledContent {
                            Button("1.99$", action: {})
                        } label: {
                            Text("☕️ Small tip")
                        }

                        LabeledContent {
                            Button("5.00$", action: {})
                        } label: {
                            Text("🥐 Medium tip")
                        }

                        LabeledContent {
                            Button("10.00$", action: {})
                        } label: {
                            Text("🥙 Big tip")
                        }
                    }
                    .font(.title3)
                    .buttonStyle(.borderedProminent)
                } label: {
                    Label("Leave tips", systemImage: "heart.square.fill")
                        .settingsRowAccent(.pink)
                }
            }
            .padding()
        }
        .labelStyle(PremiumGroupTitleLabelStyle())
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

private struct PremiumGroupTitleLabelStyle: LabelStyle {
    @Environment(\.settingsRowAccent) var settingsRowAccent

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            if let settingsRowAccent {
                configuration.icon
                    .font(.title.bold())
                    .foregroundStyle(settingsRowAccent)
            }
        }
    }
}
