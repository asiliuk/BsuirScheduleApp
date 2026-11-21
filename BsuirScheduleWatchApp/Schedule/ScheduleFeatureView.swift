import SwiftUI
import ComposableArchitecture

struct ScheduleFeatureView: View {
    let store: StoreOf<ScheduleFeature>

    var body: some View {
        switch store.case {
        case .group(let store):
            GroupScheduleFeatureView(store: store)
        }
    }
}
