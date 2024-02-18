import SwiftUI
import ComposableArchitecture
import BsuirUI

struct LoadedGroupsFeatureView: View {
    @Perception.Bindable var store: StoreOf<LoadedGroupsFeature>
    let searchStore: StoreOf<GroupsSearch>
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
            .overlay {
                if #available(iOS 17, *) {
                    if store.isEmpty {
                        ContentUnavailableView.search
                    }
                }
            }
            .groupsSearchable(store: searchStore)
        }
    }
}
