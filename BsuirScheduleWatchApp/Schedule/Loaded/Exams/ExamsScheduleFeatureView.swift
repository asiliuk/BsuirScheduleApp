import SwiftUI
import ComposableArchitecture
import BsuirUI
import ScheduleCore
import BsuirCore

struct ExamsScheduleFeatureView: View {
    let store: StoreOf<ExamsScheduleFeature>

    var body: some View {
        if store.days.isEmpty {
            ExamsEmptyView() {
                store.send(.switchToScheduleTapped)
            }
        } else {
            List {
                ScheduleSourceHeaderView(
                    source: .exams,
                    start: store.startDate,
                    end: store.endDate
                )

                ForEach(store.scope(\.days, action: \.days)) { store in
                    DaySectionFeatureView(
                        store: store,
                        showPairWeeks: false
                    )
                }
            }
        }
    }
}
