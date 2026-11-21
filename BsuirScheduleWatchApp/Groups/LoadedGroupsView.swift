import SwiftUI
import BsuirApi
import ComposableArchitecture

struct LoadedGroupsView: View {
    let store: StoreOf<LoadedGroupsFeature>
    let refresh: () async -> Void

    var body: some View {
        List {
            ForEach(store.groups) { group in
                Button(group.name) {
                    store.send(.rowTapped(group.name))
                }
            }
        }
        .refreshable { await refresh() }
    }
}
