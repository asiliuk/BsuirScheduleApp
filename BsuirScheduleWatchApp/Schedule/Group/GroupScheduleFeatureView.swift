import SwiftUI
import ComposableArchitecture

struct GroupScheduleFeatureView: View {
    let store: StoreOf<GroupScheduleFeature>

    var body: some View {
        Text("Schedule: \(store.name)")
    }
}
