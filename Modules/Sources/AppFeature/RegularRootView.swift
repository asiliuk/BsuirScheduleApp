import SwiftUI
import GroupsFeature
import LecturersFeature
import AboutFeature
import ComposableArchitecture

struct RegularRootView: View {
    struct ViewState: Equatable {
        var selection: CurrentSelection
        var overlay: CurrentOverlay?

        init(state: AppFeature.State) {
            self.selection = state.selection
            self.overlay = state.overlay
        }
    }

    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: { ViewState(state: $0) }) { viewStore in
            NavigationView {
                TabView(selection: viewStore.binding(get: \.selection, send: AppFeature.Action.setSelection)) {
                    // Placeholder
                    // When in NavigationView first tab is not visible on iPad
                    Text("Oops").opacity(0)

                    GroupsFeatureView(
                        store: store.scope(
                            state: \.groups,
                            action: AppFeature.Action.groups
                        )
                    )
                    .tag(CurrentSelection.groups)
                    .tabItem { Label.groups }

                    LecturersFeatureView(
                        store: store.scope(
                            state: \.lecturers,
                            action: AppFeature.Action.lecturers
                        )
                    )
                    .tag(CurrentSelection.lecturers)
                    .tabItem { Label.lecturers }
                }
                .toolbar {
                    Button {
                        viewStore.send(.showAboutButtonTapped)
                    } label: {
                        Label.about
                    }
                }

                SchedulePlaceholder()
            }
            // TODO: Use unwraping API here from SwiftUINavigation
            // And merge overlay enum with selection enum
            .sheet(item: viewStore.binding(get: \.overlay, send: AppFeature.Action.setOverlay)) { overlay in
                switch overlay {
                case .about:
                    NavigationView {
                        AboutView(
                            store: store.scope(
                                state: \.about,
                                action: AppFeature.Action.about
                            )
                        )
                    }
                }
            }
        }
    }
}

private struct SchedulePlaceholder: View {
    var body: some View {
        Text("screen.schedule.placeholder.title")
    }
}
