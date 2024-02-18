import SwiftUI
import ComposableArchitecture
import BsuirUI

struct LoadedGroupsFeatureView: View {
    @Perception.Bindable var store: StoreOf<LoadedGroupsFeature>
    let refresh: () async -> Void

    var body: some View {
        WithPerceptionTracking {
            ScrollableToTopList(isOnTop: $store.isOnTop) {
                ForEach(0..<100) { index in
                    Text("Row \(index)")
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await refresh() }
        }
    }
}
