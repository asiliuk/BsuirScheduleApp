import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

struct ExamsScheduleView: View {
    struct ViewState: Equatable {
        var isOnTop: Bool
        var days: [ScheduleDayViewModel]
    }

    let store: StoreOf<ExamsScheduleFeature>
    let pairDetails: ScheduleGridViewPairDetails

    var body: some View {
        WithViewStore(
            store,
            observe: { ViewState(isOnTop: $0.isOnTop, days: $0.days) }
        ) { viewStore in
            switch viewStore.days {
            case []:
                ScheduleEmptyView()
            case let days:
                ScheduleGridView(
                    days: days,
                    loading: .never,
                    pairDetails: pairDetails,
                    isOnTop: viewStore.binding(
                        get: \.isOnTop,
                        send: { .setIsOnTop($0) }
                    )
                )
            }
        }
    }
}
