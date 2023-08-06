import SwiftUI
import BsuirUI
import GroupsFeature
import LecturersFeature
import SettingsFeature
import PremiumClubFeature
import ComposableArchitecture

struct RegularRootView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: \.selection) { viewStore in
            NavigationView {
                TabView(selection: viewStore.binding(send: AppFeature.Action.setSelection)) {
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
                    .tabItem { GroupsLabel() }

                    LecturersFeatureView(
                        store: store.scope(
                            state: \.lecturers,
                            action: AppFeature.Action.lecturers
                        )
                    )
                    .tag(CurrentSelection.lecturers)
                    .tabItem { LecturersLabel() }
                }
                .toolbar {
                    Button {
                        viewStore.send(.showSettingsButtonTapped)
                    } label: {
                        SettingsLabel()
                    }
                }

                SchedulePlaceholder()
            }
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /AppFeature.State.Destination.settings,
                action: AppFeature.Action.DestinationAction.settings
            ) { store in
                ModalNavigationStack {
                    SettingsFeatureView(store: store)
                }
            }
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /AppFeature.State.Destination.premiumClub,
                action: AppFeature.Action.DestinationAction.premiumClub
            ) { store in
                ModalNavigationStack {
                    PremiumClubFeatureView(store: store)
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
