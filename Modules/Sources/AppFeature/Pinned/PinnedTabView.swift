import SwiftUI
import BsuirUI
import EntityScheduleFeature
import PremiumClubFeature
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
    struct ViewState: Equatable {
        var hasPremium: Bool
        var showModalPremiumClub: Bool

        init(_ state: PinnedTabFeature.State) {
            hasPremium = state.premiumClub.hasPremium
            showModalPremiumClub = state.showModalPremiumClub
        }
    }
    let store: StoreOf<PinnedTabFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Group {
                if viewStore.hasPremium {
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
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showModalPremiumClub,
                    send: PinnedTabFeature.Action.setShowModalPremiumClub
                )
            ) {
                ModalNavigationStack {
                    PremiumClubFeatureView(
                        store: store.scope(
                            state: \.premiumClub,
                            action: PinnedTabFeature.Action.premiumClub
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
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
