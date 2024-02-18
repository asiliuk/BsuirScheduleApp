import SwiftUI
import ComposableArchitecture
import LoadableFeature
import EntityScheduleFeature

public struct GroupsFeatureViewV2: View {
    @Perception.Bindable var store: StoreOf<GroupsFeatureV2>

    public init(store: StoreOf<GroupsFeatureV2>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                LoadingView(
                    store: store.scope(state: \.groups, action: \.groups),
                    inProgress: {
                        WithPerceptionTracking {
                            GroupsPlaceholderView(
                                hasPinned: store.hasPinnedPlaceholder,
                                numberOfFavorites: store.favoritesPlaceholderCount
                            )
                        }
                    },
                    failed: LoadingErrorView.init,
                    loaded: LoadedGroupsFeatureView.init
                )
                .navigationTitle("screen.groups.navigation.title")
                .navigationBarTitleDisplayMode(.inline)
            } destination: { store in
                switch store.state {
                case .group:
                    if let groupStore = store.scope(state: \.group, action: \.group) {
                        GroupScheduleView(store: groupStore)
                    }

                case .lector:
                    if let lectorStore = store.scope(state: \.lector, action: \.lector) {
                        LectorScheduleView(store: lectorStore)
                    }
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}
