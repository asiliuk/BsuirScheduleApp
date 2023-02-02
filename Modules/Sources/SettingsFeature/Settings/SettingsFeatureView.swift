import SwiftUI
import BsuirCore
import BsuirUI
import ScheduleCore
import ReachabilityFeature
import PremiumClubFeature
import ComposableArchitecture
import ComposableArchitectureUtils

enum SettingsFeatureDestination: Hashable {
    case premiumClub
    case appIcon
    case appearance
    case networkAndData
    case about
}

public struct SettingsFeatureView: View {
    struct ViewState: Equatable {
        var isOnTop: Bool
        var showModalPremiumClub: Bool

        init(_ state: SettingsFeature.State) {
            isOnTop = state.isOnTop
            showModalPremiumClub = state.showModalPremiumClub
        }
    }

    public let store: StoreOf<SettingsFeature>
    @State var hasActivePass = false
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ScrollableToTopList(
                isOnTop: viewStore.binding(
                    get: \.isOnTop,
                    send: { .view(.setIsOnTop($0)) }
                )
            ) {
                Section {
                    NavigationLink(value: SettingsFeatureDestination.premiumClub) {
                        PremiumClubLabel(
                            store: store.scope(
                                state: \.premiumClub,
                                reducerAction: { .premiumClub($0) }
                            )
                        )
                    }
                }

                Section {
                    AppIconFeatureNavigationLink(
                        value: .appIcon,
                        store: store.scope(
                            state: \.appIcon,
                            reducerAction: { .appIcon($0) }
                        )
                    )

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
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showModalPremiumClub,
                    send: { .view(.setShowModalPremiumClub($0)) }
                )
            ) {
                ModalNavigationStack {
                    PremiumClubFeatureView(
                        store: store.scope(
                            state: \.premiumClub,
                            reducerAction: { .premiumClub($0) }
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationDestination(for: SettingsFeatureDestination.self) { destination in
                switch destination {
                case .premiumClub:
                    PremiumClubFeatureView(
                        store: store.scope(
                            state: \.premiumClub,
                            reducerAction: { .premiumClub($0) }
                        )
                    )

                case .appIcon:
                    AppIconFeatureView(
                        store: store.scope(
                            state: \.appIcon,
                            reducerAction: { .appIcon($0) }
                        )
                    )

                case .appearance:
                    AppearanceFeatureView(
                        store: store.scope(
                            state: \.appearance,
                            reducerAction: { .appearance($0) }
                        )
                    )

                case .networkAndData:
                    NetworkAndDataFeatureView(
                        store: store.scope(
                            state: \.networkAndData,
                            reducerAction: { .networkAndData($0) }
                        )
                    )

                case .about:
                    AboutFeatureView(
                        store: store.scope(
                            state: \.about,
                            reducerAction: { .about($0) }
                        )
                    )
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
