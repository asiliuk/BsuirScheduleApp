import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct ContiniousScheduleView: View {
    struct ViewState: Equatable {
        var isOnTop: Bool
        var days: [ScheduleDayViewModel]
        var doneLoading: Bool
    }

    let store: StoreOf<ContiniousScheduleFeature>
    let pairDetails: ScheduleGridViewPairDetails

    var body: some View {
        WithViewStore(
            store,
            observe: { ViewState(isOnTop: $0.isOnTop, days: $0.days, doneLoading: $0.doneLoading) }
        ) { viewStore in
            switch viewStore.days {
            case []:
                ScheduleEmptyView()
            case let days:
                ScheduleGridView(
                    days: days,
                    loading: viewStore.doneLoading
                        ? .finished
                        : .loadMore { viewStore.send(.loadMoreIndicatorAppear) },
                    pairDetails: pairDetails,
                    pairShowWeeks: false,
                    isOnTop: viewStore.binding(
                        get: \.isOnTop,
                        send: { .setIsOnTop($0) }
                    )
                )
            }
        }
    }
}
