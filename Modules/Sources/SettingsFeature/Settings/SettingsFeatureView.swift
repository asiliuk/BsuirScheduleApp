import SwiftUI
import BsuirCore
import BsuirUI
import ScheduleCore
import ReachabilityFeature
import PremiumClubFeature
import ComposableArchitecture

enum SettingsFeatureDestination: Hashable {
    case premiumClub
    case appIcon
    case appearance
    case networkAndData
    case about
    case roadmap
}

public struct SettingsFeatureView: View {
    @Perception.Bindable public var store: StoreOf<SettingsFeature>
    @State var hasActivePass = false
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ScrollableToTopList(isOnTop: $store.isOnTop) {
                Section {
                    NavigationLink(value: SettingsFeatureDestination.premiumClub) {
                        PremiumClubLabel(
                            store: store.scope(
                                state: \.premiumClub,
                                action: \.premiumClub
                            )
                        )
                    }
                }

                if let whatsNewStore = store.scope(state: \.whatsNew, action: \.whatsNew) {
                    WhatsNewSectionView(store: whatsNewStore)
                }

                Section {
                    AppIconFeatureNavigationLink(
                        value: .appIcon,
                        store: store.scope(
                            state: \.appIcon,
                            action: \.appIcon
                        )
                    )

                    NavigationLink(value: SettingsFeatureDestination.roadmap) {
                        Label("screen.settings.roadmap.navigation.title", systemImage: "list.bullet.circle.fill")
                            .settingsRowAccent(Color.purple)
                    }

                    NavigationLink(value: SettingsFeatureDestination.appearance) {
                        Label("screen.settings.appearance.navigation.title", systemImage: "circle.lefthalf.filled")
                            .settingsRowAccent(Color.orange)
                    }

                    NavigationLink(value: SettingsFeatureDestination.networkAndData) {
                        Label("screen.settings.networkAndData.navigation.title", systemImage: "network")
                            .settingsRowAccent(Color.blue)
                    }

                    NavigationLink(value: SettingsFeatureDestination.about) {
                        Label("screen.settings.about.navigation.title", systemImage: "info.circle.fill")
                            .settingsRowAccent(Color.indigo)
                    }
                }
            }
            .navigationDestination(for: SettingsFeatureDestination.self) { destination in
                switch destination {
                case .premiumClub:
                    PremiumClubFeatureView(
                        store: store.scope(
                            state: \.premiumClub,
                            action: \.premiumClub
                        )
                    )

                case .appIcon:
                    AppIconFeatureView(
                        store: store.scope(
                            state: \.appIcon,
                            action: \.appIcon
                        )
                    )

                case .appearance:
                    AppearanceFeatureView(
                        store: store.scope(
                            state: \.appearance,
                            action: \.appearance
                        )
                    )

                case .networkAndData:
                    NetworkAndDataFeatureView(
                        store: store.scope(
                            state: \.networkAndData,
                            action: \.networkAndData
                        )
                    )

                case .about:
                    AboutFeatureView(
                        store: store.scope(
                            state: \.about,
                            action: \.about
                        )
                    )

                case .roadmap:
                    RoadmapFeatureView(
                        store: store.scope(
                            state: \.roadmap,
                            action: \.roadmap
                        )
                    )
                }
            }
            .labelStyle(.settings)
            .listStyle(.insetGrouped)
            .navigationTitle("screen.settings.navigation.title")
        }
    }
}

// MARK: - Previews

struct SettingsFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsFeatureView(
                store: Store(initialState: .init()) {
                    SettingsFeature()
                }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
