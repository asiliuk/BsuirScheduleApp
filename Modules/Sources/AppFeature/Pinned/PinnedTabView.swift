import SwiftUI
import EntityScheduleFeature
import ComposableArchitecture

struct PinnedTabView: View {
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        NavigationStack {
            PinnedTabContentView(store: store)
        }
        .tabItem {
            PinnedTabItem(store: store)
        }
    }
}

private struct PinnedTabContentView: View {
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        WithViewStore(store, observe: \.premiumClub.hasPremium) { viewStore in
            if viewStore.state {
                IfLetStore(
                    store.scope(
                        state: \.schedule,
                        action: PinnedTabFeature.Action.schedule
                    )
                ) { store in
                    PinnedScheduleView(store: store)
                } else: {
                    PinnedScheduleEmptyView()
                        // Reset navigation title left from schedule screen
                        .navigationTitle("")
                }
            } else {
                PinnedScheduleLockedView {
                    viewStore.send(.learnAboutPremiumClubTapped)
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
            observe: { $0.premiumClub.hasPremium ? $0.schedule?.title : nil }
        ) { viewStore in
            Group {
                if let title = viewStore.state {
                    PinnedLabel(title: title)
                } else {
                    EmptyPinnedLabel()
                }
            }
            .task { await viewStore.send(.premiumClub(.task)).finish() }
        }
    }
}
