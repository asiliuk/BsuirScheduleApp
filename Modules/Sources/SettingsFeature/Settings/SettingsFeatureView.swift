import SwiftUI
import BsuirCore
import BsuirUI
import ScheduleCore
import ReachabilityFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct SettingsFeatureView: View {
    public let store: StoreOf<SettingsFeature>
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.isOnTop) { viewStore in
            ScrollableToTopList(isOnTop: viewStore.binding(send: { .view(.setIsOnTop($0)) })) {
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
                        .settingsRowAccentColor(.orange)
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
                        .settingsRowAccentColor(.blue)
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
                        .settingsRowAccentColor(.indigo)
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
        SettingsFeatureView(store: Store(initialState: .init(), reducer: SettingsFeature()))
    }
}
