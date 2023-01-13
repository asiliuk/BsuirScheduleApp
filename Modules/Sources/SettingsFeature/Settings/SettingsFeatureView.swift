import SwiftUI
import BsuirCore
import BsuirUI
import ScheduleCore
import ReachabilityFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct SettingsFeatureView: View {
    public let store: StoreOf<SettingsFeature>
    @State var hasActivePass = false
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.isOnTop) { viewStore in
            ScrollableToTopList(isOnTop: viewStore.binding(send: { .view(.setIsOnTop($0)) })) {
                Section {
                    NavigationLink {
                        Text("Put some subscriptions here")
                    } label: {
                        HStack(spacing: 12) {
                            SettingsRowIcon(fill: .premiumGradient) {
                                Image(systemName: "flame.fill")
                                    .font(.title2)
                            }

                            VStack(alignment: .leading) {
                                Text("Premium Club")
                                    .font(.headline)

                                Group {
                                    if hasActivePass {
                                        Text("\(Image(systemName: "checkmark.seal.fill")) Active pass: **2022-2023**")
                                    } else {
                                        Text("No active pass")
                                    }
                                }
                                .onTapGesture { hasActivePass.toggle() }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section {
                    AppIconFeatureView(
                        store: store.scope(
                            state: \.appIcon,
                            reducerAction: { .appIcon($0) }
                        )
                    )

                    NavigationLink {
                        AppearanceFeatureView(
                            store: store.scope(
                                state: \.appearance,
                                reducerAction: { .appearance($0) }
                            )
                        )
                    } label: {
                        Label("screen.settings.appearance.navigation.title", systemImage: "circle.lefthalf.filled")
                            .settingsRowAccent(Color.orange)
                    }

                    NavigationLink {
                        NetworkAndDataFeatureView(
                            store: store.scope(
                                state: \.networkAndData,
                                reducerAction: { .networkAndData($0) }
                            )
                        )
                    } label: {
                        Label("screen.settings.networkAndData.navigation.title", systemImage: "network")
                            .settingsRowAccent(Color.blue)
                    }

                    NavigationLink {
                        AboutFeatureView(
                            store: store.scope(
                                state: \.about,
                                reducerAction: { .about($0) }
                            )
                        )
                    } label: {
                        Label("screen.settings.about.navigation.title", systemImage: "info.circle.fill")
                            .settingsRowAccent(Color.indigo)
                    }
                }
            }
            .labelStyle(SettingsLabelStyle())
            .listStyle(.insetGrouped)
            .navigationTitle("screen.settings.navigation.title")
        }
    }
}

// MARK: - Previews

struct SettingsFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsFeatureView(store: Store(initialState: .init(), reducer: SettingsFeature()))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
