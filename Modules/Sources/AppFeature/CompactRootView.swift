import SwiftUI
import BsuirCore
import BsuirUI
import SettingsFeature
import GroupsFeature
import LecturersFeature
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture

struct CompactRootView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: \.selection) { viewStore in
            TabView(selection: viewStore.binding(send: AppFeature.Action.setSelection)) {
                PinnedTabView(
                    store: store.scope(
                        state: \.pinnedTab,
                        action: AppFeature.Action.pinnedTab
                    )
                )
                .tag(CurrentSelection.pinned)

                GroupsFeatureTab(
                    store: store.scope(
                        state: \.groups,
                        action: AppFeature.Action.groups
                    )
                )
                .tag(CurrentSelection.groups)

                LecturersFeatureTab(
                    store: store.scope(
                        state: \.lecturers,
                        action: AppFeature.Action.lecturers
                    )
                )
                .tag(CurrentSelection.lecturers)

                SettingsFeatureTab(
                    store: store.scope(
                        state: \.settings,
                        action: AppFeature.Action.settings
                    )
                )
                .tag(CurrentSelection.settings)
            }
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /AppFeature.State.Destination.premiumClub,
                action: AppFeature.Action.DestinationAction.premiumClub
            ) { store in
                ModalNavigationStack {
                    PremiumClubFeatureView(store: store)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

private struct GroupsFeatureTab: View {
    let store: StoreOf<GroupsFeature>

    var body: some View {
        NavigationStack {
            GroupsFeatureView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem { GroupsLabel() }
    }
}

private struct LecturersFeatureTab: View {
    let store: StoreOf<LecturersFeature>

    var body: some View {
        NavigationStack {
            LecturersFeatureView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem { LecturersLabel() }
    }
}

private struct SettingsFeatureTab: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        WithViewStore(store, observe: \.path) { viewStore in
            NavigationStack(path: viewStore.binding(send: { .setPath($0) })) {
                SettingsFeatureView(store: store)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .tabItem { SettingsLabel() }
    }
}
