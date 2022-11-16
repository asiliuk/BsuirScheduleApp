import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct ContiniousScheduleView: View {
    let store: StoreOf<ContiniousScheduleFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScheduleGridView(
                days: viewStore.days,
                loadMore: { viewStore.send(.loadMoreIndicatorAppear) },
                isOnTop: viewStore.binding(\.$isOnTop)
            )
            .task { await viewStore.send(.task).finish() }
        }
    }
}
