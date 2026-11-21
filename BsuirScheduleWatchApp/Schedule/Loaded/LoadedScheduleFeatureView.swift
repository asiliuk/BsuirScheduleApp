import SwiftUI
import ComposableArchitecture
import ScheduleCore
import BsuirCore

struct LoadedScheduleFeatureView: View {
    let store: StoreOf<LoadedScheduleFeature>
    let refresh: () async -> Void

    var body: some View {
        VStack {
            Text("Loaded schedule")

            if let start = store.response.startDate, let end = store.response.endDate {
                Text((start..<end).formatted(.scheduleDates))
            }

            if let start = store.response.startExamsDate, let end = store.response.endExamsDate {
                Text("Exams: \((start..<end).formatted(.scheduleDates))")
            }
        }
        .refreshable { await refresh() }
    }
}
