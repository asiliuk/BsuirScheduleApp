import SwiftUI
import ComposableArchitecture

struct ContinuousScheduleView: View {
    let store: StoreOf<ContinuousScheduleFeature>

    var body: some View {
        ScheduleListView(
            store: store.scope(
                state: \.scheduleList,
                action: \.scheduleList
            )
        )
        .task { store.send(.task) }
    }
}
