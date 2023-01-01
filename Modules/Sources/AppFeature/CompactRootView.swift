import SwiftUI
import BsuirCore
import SettingsFeature
import GroupsFeature
import LecturersFeature
import EntityScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils

struct CompactRootView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: \.selection) { viewStore in
            TabView(selection: viewStore.binding(get: { $0 }, send: AppFeature.Action.setSelection)) {
                IfLetStore(
                    store.scope(
                        state: \.pinned,
                        action: { .pinned($0) }
                    )
                ) { store in
                    WithViewStore(store, observe: \.title) { viewStore in
                        NavigationStack {
                            PinnedScheduleView(
                                store: store.scope(state: \.schedule)
                            )
                        }
                        .tag(CurrentSelection.pinned)
                        .tabItem { Label.pinned(title: viewStore.state) }
                    }
                }

                NavigationStack {
                    GroupsFeatureView(
                        store: store.scope(
                            state: \.groups,
                            action: AppFeature.Action.groups
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tag(CurrentSelection.groups)
                .tabItem { Label.groups }

                NavigationStack {
                    LecturersFeatureView(
                        store: store.scope(
                            state: \.lecturers,
                            action: AppFeature.Action.lecturers
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tag(CurrentSelection.lecturers)
                .tabItem { Label.lecturers }

                NavigationStack {
                    SettingsFeatureView(
                        store: store.scope(
                            state: \.settings,
                            action: AppFeature.Action.settings
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tag(CurrentSelection.settings)
                .tabItem { Label.settings }
            }
        }
    }
}
