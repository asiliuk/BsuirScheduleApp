import SwiftUI
import BsuirUI
import ComposableArchitecture

struct PinnedFeatureView: View {
    let store: StoreOf<PinnedFeature>

    var body: some View {
        NavigationStack {
            if !store.isPremiumUser {
                PinnedScheduleLockedView(onLearnMoreTapped: {})
            } else if let store = store.scope(\.schedule, action: \.schedule) {
                ScheduleFeatureView(store: store)
            } else {
                PinnedScheduleEmptyView()
            }
        }
        .task { await store.send(.task).finish() }
    }
}
