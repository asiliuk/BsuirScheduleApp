import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

struct ExamsScheduleView: View {
    let store: StoreOf<ExamsScheduleFeature>
    let pairDetails: ScheduleGridViewPairDetails

    var body: some View {
        WithViewStore(store, observe: \.days) { viewStore in
            switch viewStore.state {
            case []:
                ScheduleEmptyView()
            case let days:
                ScheduleGridView(
                    days: days,
                    loading: .never,
                    pairDetails: pairDetails,
                    isOnTop: .constant(false)
                )
            }
        }
    }
}
