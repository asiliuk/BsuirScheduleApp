import SwiftUI
import ComposableArchitecture
import ScheduleCore
import BsuirCore

struct LoadedScheduleFeatureView: View {
    let store: StoreOf<LoadedScheduleFeature>
    let refresh: () async -> Void

    var body: some View {
        VStack {
            DayScheduleFeatureView(
                store: store.scope(\.day, action: \.day)
            )
        }
        .refreshable { await refresh() }
    }
}
