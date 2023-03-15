import SwiftUI
import BsuirCore
import BsuirUI
import SettingsFeature
import GroupsFeature
import LecturersFeature
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture
import ComposableArchitectureUtils

struct CompactRootView: View {
    struct ViewState: Equatable {
        var selection: CurrentSelection
        var overlay: CurrentOverlay?

        init(_ state: AppFeature.State) {
            self.selection = state.selection
            self.overlay = state.overlay
        }
    }

    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            TabView(selection: viewStore.binding(get: \.selection, send: AppFeature.Action.setSelection)) {
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
                unwrapping: viewStore.binding(get: \.overlay, send: AppFeature.Action.setOverlay),
                case: /CurrentOverlay.premiumClub
            ) { _ in
                ModalNavigationStack {
                    PremiumClubFeatureView(
                        store: store.scope(
                            state: \.premiumClub,
                            action: AppFeature.Action.premiumClub
                        )
                    )
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
            NavigationStack(path: viewStore.binding(send: { .view(.setPath($0)) })) {
                SettingsFeatureView(store: store)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .tabItem { SettingsLabel() }
    }
}
