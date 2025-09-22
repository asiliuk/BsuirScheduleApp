import SwiftUI
import BsuirCore
import BsuirUI
import ScheduleCore
import ReachabilityFeature
import PremiumClubFeature
import ComposableArchitecture
import WhatsNewKit

enum SettingsFeatureDestination: Hashable {
    case premiumClub
    case appIcon
    case appearance
    case networkAndData
    case about
}

public struct SettingsFeatureView: View {
    @Perception.Bindable public var store: StoreOf<SettingsFeature>
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var selection: SettingsFeatureDestination?

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                List(selection: $store.selectedDestination) {
                    Section {
                        NavigationLink(value: SettingsFeatureDestination.premiumClub) {
                            PremiumClubLabelView(
                                store: store.scope(
                                    state: \.premiumClubLabel,
                                    action: \.premiumClubLabel
                                )
                            )
                        }
                        .accessibilityIdentifier("settings-premium-club-row")
                    }

                    if let whatsNew = store.whatsNew {
                        Section {
                            Button {
                                store.send(.whatsNewTapped)
                            } label: {
                                Label("screen.settings.whatsNew.navigation.title", systemImage: "sparkles")
                                    .settingsRowAccent(Color.red)
                                    .badge(whatsNew.version.description)
                            }
                            .foregroundColor(.primary)
                            .accessibilityIdentifier("settings-whats-new-row")
                        }
                    }

                    Section {
                        AppIconLabelNavigationLink(
                            value: .appIcon,
                            store: store.scope(state: \.appIconLabel, action: \.appIconLabel)
                        )
                        .accessibilityIdentifier("settings-app-icon-row")

                        NavigationLink(value: SettingsFeatureDestination.appearance) {
                            Label("screen.settings.appearance.navigation.title", systemImage: "circle.lefthalf.filled")
                                .settingsRowAccent(Color.orange)
                        }
                        .accessibilityIdentifier("settings-appearance-row")

                        NavigationLink(value: SettingsFeatureDestination.networkAndData) {
                            Label("screen.settings.networkAndData.navigation.title", systemImage: "network")
                                .settingsRowAccent(Color.blue)
                        }
                        .accessibilityIdentifier("settings-network-row")

                        NavigationLink(value: SettingsFeatureDestination.about) {
                            Label("screen.settings.about.navigation.title", systemImage: "info.circle.fill")
                                .settingsRowAccent(Color.indigo)
                        }
                        .accessibilityIdentifier("settings-about-row")
                    }
                }
                .labelStyle(.settings)
                .listStyle(.insetGrouped)
                .navigationTitle("screen.settings.navigation.title")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(
                    item: $store.scope(
                        state: \.destination?.whatsNew,
                        action: \.destination.whatsNew
                    )
                ) { store in
                    WhatsNewFeatureView(store: store)
                }
                .bsuirRemovingSidebarToggle()
            } detail: {
                if let destinationStore = store.scope(state: \.destination, action: \.destination.presented) {
                    switch destinationStore.case {
                    case .premiumClub(let store):
                        PremiumClubFeatureView(store: store)
                    case .appIcon(let store):
                        AppIconFeatureView(store: store)
                    case .appearance(let store):
                        AppearanceFeatureView(store: store)
                    case .networkAndData(let store):
                        NetworkAndDataFeatureView(store: store)
                    case .about(let store):
                        AboutFeatureView(store: store)
                    case .whatsNew:
                        EmptyView()
                    }
                } else {
                    Text("screen.settings.select_something.title")
                }
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
}

// MARK: - Previews

struct SettingsFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFeatureView(
            store: Store(initialState: .init()) {
                SettingsFeature()
            }
        )
    }
}
