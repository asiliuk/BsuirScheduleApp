import SwiftUI
import ComposableArchitecture
import BsuirUI

struct DayScheduleFeatureView: View {
    let store: StoreOf<DayScheduleFeature>

    var body: some View {
        if store.days.isEmpty {
            ScheduleEmptyView()
        } else {
            List {
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
