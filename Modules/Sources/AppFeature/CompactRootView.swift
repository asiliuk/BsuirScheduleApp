import SwiftUI
import BsuirCore
import AboutFeature
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
                        NavigationView {
                            PinnedScheduleView(
                                store: store.scope(state: \.schedule)
                            )
                        }
                        .tag(CurrentSelection.pinned)
                        .tabItem { Label.pinned(title: viewStore.state) }
                    }
                }

                NavigationView {
                    GroupsFeatureView(
                        store: store.scope(
                            state: \.groups,
                            action: AppFeature.Action.groups
                        )
                    )
                }
                .tag(CurrentSelection.groups)
                .tabItem { Label.groups }

                NavigationView {
                    LecturersView(
                        store: store.scope(
                            state: \.lecturers,
                            action: AppFeature.Action.lecturers
                        )
                    )
                }
                .tag(CurrentSelection.lecturers)
                .tabItem { Label.lecturers }

                NavigationView {
                    AboutView(
                        store: store.scope(
                            state: \.about,
                            action: AppFeature.Action.about
                        )
                    )
                }
                .tag(CurrentSelection.about)
                .tabItem { Label.about }
            }
        }
    }
}

//extension View {
//    func tab(_ selection: CurrentSelection) -> some View {
//        self
//            .tabItem { selection.label }
//            .tag(selection)
//    }
//}
