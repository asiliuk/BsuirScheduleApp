import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture

struct ExamsScheduleView: View {
    let store: StoreOf<ExamsScheduleFeature>

    var body: some View {
        WithPerceptionTracking {
            ScheduleListView(
                store: store.scope(
                    state: \.scheduleList,
                    action: \.scheduleList
                )
            )
        }
    }
}
