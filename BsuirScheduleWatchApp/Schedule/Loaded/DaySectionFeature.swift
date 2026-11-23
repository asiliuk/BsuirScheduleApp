import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi

@Reducer
struct DaySectionFeature {
    @ObservableState
    struct State {
        nonisolated enum Day: Hashable {
            case weekDay(DaySchedule.WeekDay)
        }

        let day: Day
        var pairs: [PairViewModel]
    }
}

// MARK: - Identifiable

extension DaySectionFeature.State: Identifiable {
    var id: Day { day }
}
