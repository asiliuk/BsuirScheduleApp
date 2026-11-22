import SwiftUI
import ComposableArchitecture

struct DayScheduleFeatureView: View {
    let store: StoreOf<DayScheduleFeature>

    var body: some View {
        List {
            ForEach(store.scope(\.days, action: \.days)) { store in
                DaySectionFeatureView(store: store)
            }
        }
    }
}
