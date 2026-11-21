import SwiftUI
import ComposableArchitecture
import ScheduleCore

struct DaySectionFeatureView: View {
    let store: StoreOf<DaySectionFeature>

    var body: some View {
        Section {
            ForEach(store.pairs) { pair in
                Text(pair.subject ?? "--")
            }
        } header: {
            Text(store.title)
        }
    }
}
