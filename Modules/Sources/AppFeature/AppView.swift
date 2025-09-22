import SwiftUI
import BsuirCore
import BsuirUI
import SettingsFeature
import GroupsFeature
import LecturersFeature
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture

public enum CurrentSelection: Hashable {
    case pinned
    case groups
    case lecturers
    case settings
}

public struct AppView: View {
    @Perception.Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.selection.sending(\.setSelection)) {
                PinnedTabView(
                    store: store.scope(
                        state: \.pinnedTab,
                        action: \.pinnedTab
                    )
                )
                .tag(CurrentSelection.pinned)

                GroupsFeatureTab(
                    store: store.scope(
                        state: \.groups,
                        action: \.groups
                    )
                )
                .tag(CurrentSelection.groups)

                LecturersFeatureTab(
                    store: store.scope(
                        state: \.lecturers,
                        action: \.lecturers
                    )
                )
                .tag(CurrentSelection.lecturers)

                SettingsFeatureTab(
                    store: store.scope(
                        state: \.settings,
                        action: \.settings
                    )
                )
                .tag(CurrentSelection.settings)
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.premiumClub,
                    action: \.destination.premiumClub
                )
            ) { store in
                NavigationStack {
                    PremiumClubFeatureView(store: store)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            CloseModalToolbarItem {
                                self.store.send(.closePremiumClubButtonTapped)
                            }
                        }
                }
            }
            .bsuirTabbarSidebarAdaptable()
        }
        .onOpenURL(perform: { store.send(.handleDeeplink($0)) })
        .task { await store.send(.task).finish() }
        .environmentObject({ () -> PairFormDisplayService in
            @Dependency(\.pairFormDisplayService) var pairFormDisplayService
            return pairFormDisplayService
        }())
    }
}

// MARK: - Tabs

private struct GroupsFeatureTab: View {
    let store: StoreOf<GroupsFeature>

    var body: some View {
        GroupsFeatureView(
            store: store
        )
        .tabItem {
            Label("view.tabBar.groups.title", systemImage: "person.2")
                .accessibilityIdentifier("tabview-tab-groups")
        }
    }
}

private struct LecturersFeatureTab: View {
    let store: StoreOf<LecturersFeature>

    var body: some View {
        LecturersFeatureView(
            store: store
        )
        .tabItem {
            Label("view.tabBar.lecturers.title", systemImage: "person.text.rectangle")
                .accessibilityIdentifier("tabview-tab-lecturers")
        }
    }
}

private struct SettingsFeatureTab: View {
    @Perception.Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        WithPerceptionTracking {
            SettingsFeatureView(
                store: store
            )
            .tabItem {
                Label("view.tabBar.settings.title", systemImage: "gearshape")
                    .accessibilityIdentifier("tabview-tab-settings")
            }
            .badge(store.hasWhatsNew ? "✦" : nil)
        }
    }
}
