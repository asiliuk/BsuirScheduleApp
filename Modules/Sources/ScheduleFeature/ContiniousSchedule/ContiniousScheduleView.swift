import SwiftUI
import ComposableArchitecture

struct ContinuousScheduleView: View {
    let store: StoreOf<ContinuousScheduleFeature>

    var body: some View {
        WithPerceptionTracking {
            ScheduleListView(
                store: store.scope(
                    state: \.scheduleList,
                    action: \.scheduleList
                )
            )
            .task { await store.send(.task).finish() }
        }
    }
}
