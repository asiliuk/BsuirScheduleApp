import SwiftUI
import BsuirUI
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture

struct PinnedTabView: View {
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        NavigationStack {
            // Wrapped in ZStack to fix some SwiftUI glitch when premium
            // flag is updated very fast on app launch
            ZStack { PinnedTabContentView(store: store) }
                // Reset navigation title left from schedule screen
                .navigationTitle("")
        }
        .tabItem {
            PinnedTabItem(store: store)
        }
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
                        state: \.schedule,
                        action: PinnedTabFeature.Action.schedule
                    )
                ) { store in
                    PinnedScheduleView(store: store)
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
            observe: { $0.isPremiumLocked ? nil : $0.schedule?.title }
        ) { viewStore in
            if let title = viewStore.state {
                PinnedLabel(title: title)
            } else {
                EmptyPinnedLabel()
            }
        }
    }
}
