import SwiftUI
import BsuirUI
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture

struct PinnedTabView: View {
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        PinnedTabContentView(store: store)
            .tabItem { PinnedTabItem(store: store) }
    }
}

private struct PinnedTabContentView: View {
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        WithViewStore(store, observe: \.isPremiumLocked) { viewStore in
            if viewStore.state {
                PinnedScheduleLockedView {
                    viewStore.send(.learnAboutPremiumClubTapped)
                }
            } else {
                IfLetStore(
                    store.scope(
                        state: \.pinnedSchedule,
                        action: \.pinnedSchedule
                    )
                ) { store in
                    PinnedScheduleFeatureView(store: store)
                } else: {
                    PinnedScheduleEmptyView()
                }
            }
        }
    }
}

private struct PinnedTabItem: View {
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: { $0.isPremiumLocked ? nil : $0.pinnedSchedule?.title }
        ) { viewStore in
            if let title = viewStore.state {
                Label(title, systemImage: "pin")
            } else {
                Label("view.tabBar.pinned.empty.title", systemImage: "pin")
                    .environment(\.symbolVariants, .none)
            }
        }
    }
}
