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
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: \.selection) { viewStore in
            TabView(selection: viewStore.binding(send: AppFeature.Action.setSelection)) {
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
            .sheet(store: store.scope(
                state: \.$destination.premiumClub,
                action: \.destination.premiumClub
            )) { store in
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
        }
    }
}

private struct SettingsFeatureTab: View {
    struct ViewState: Equatable {
        var path: NavigationPath
        var hasWhatsNew: Bool

        init(state: SettingsFeature.State) {
            self.path = state.path
            self.hasWhatsNew = state.hasWhatsNew
        }
    }

    let store: StoreOf<SettingsFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationStack(path: viewStore.binding(get: \.path, send: { .setPath($0) })) {
                SettingsFeatureView(store: store)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("view.tabBar.settings.title", systemImage: "gearshape")
            }
            .badge(viewStore.hasWhatsNew ? "✦" : nil)
        }
    }
}
