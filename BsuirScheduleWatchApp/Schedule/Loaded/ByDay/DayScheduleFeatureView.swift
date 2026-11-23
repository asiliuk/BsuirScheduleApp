import SwiftUI
import ComposableArchitecture
import BsuirUI
import ScheduleCore

struct DayScheduleFeatureView: View {
    let store: StoreOf<DayScheduleFeature>

    var body: some View {
        if store.days.isEmpty {
            ScheduleEmptyView()
        } else {
            List {
                ScheduleSourceHeaderView(
                    source: .compact,
                    start: store.startDate,
                    end: store.endDate
                )

                ForEach(store.scope(\.days, action: \.days)) { store in
                    DaySectionFeatureView(
                        store: store,
                        showPairWeeks: true
                    )
                }
            }
        }
    }
}
