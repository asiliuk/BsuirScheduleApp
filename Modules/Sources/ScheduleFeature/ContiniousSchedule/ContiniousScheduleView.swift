import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct ContiniousScheduleView: View {
    let store: StoreOf<ContiniousScheduleFeature>
    let pairDetails: ScheduleGridViewPairDetails

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.schedule.days {
            case []:
                ScheduleEmptyView()
            case let days:
                ScheduleGridView(
                    days: days,
                    loading: viewStore.schedule.doneLoading
                        ? .finished
                        : .loadMore { viewStore.send(.loadMoreIndicatorAppear) },
                    pairDetails: pairDetails,
                    isOnTop: viewStore.binding(get: \.isOnTop, send: { .view(.setIsOnTop($0)) })
                )
            }
        }
    }
}
