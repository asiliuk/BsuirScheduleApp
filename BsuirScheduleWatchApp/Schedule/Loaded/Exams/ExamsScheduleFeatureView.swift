import SwiftUI
import ComposableArchitecture
import BsuirUI

struct ExamsScheduleFeatureView: View {
    let store: StoreOf<ExamsScheduleFeature>

    var body: some View {
        if store.days.isEmpty {
            ExamsEmptyView() {
                store.send(.switchToScheduleTapped)
            }
        } else {
            List {
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
