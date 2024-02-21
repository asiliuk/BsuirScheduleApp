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
        WithPerceptionTracking {
            if store.isPremiumLocked {
                PinnedScheduleLockedView {
                    store.send(.learnAboutPremiumClubTapped)
                }
            } else if let store = store.scope(state: \.pinnedSchedule, action: \.pinnedSchedule) {
                PinnedScheduleFeatureView(store: store)
            } else {
                PinnedScheduleEmptyView()
            }
        }
    }
}

private struct PinnedTabItem: View {
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        WithPerceptionTracking {
            if !store.isPremiumLocked, let title = store.pinnedSchedule?.title {
                Label(title, systemImage: "pin")
            } else {
                Label("view.tabBar.pinned.empty.title", systemImage: "pin")
                    .environment(\.symbolVariants, .none)
            }
        }
    }
}
