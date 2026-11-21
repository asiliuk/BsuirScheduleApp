import Foundation
import ComposableArchitecture
import ScheduleCore

@Reducer
struct DaySectionFeature {
    @ObservableState
    struct State: Identifiable {
        let id: UUID
        let title: String
        var pairs: [PairViewModel]
    }
}
