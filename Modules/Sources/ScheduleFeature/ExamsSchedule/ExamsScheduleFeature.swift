import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import ComposableArchitecture
import Dependencies

@Reducer
public struct ExamsScheduleFeature {
    @ObservableState
    public struct State {
        var scheduleList: ScheduleListFeature.State
        var pairRowDetails: PairRowDetails?
        @Shared var sharedNow: Date

        init(
            exams: [Pair],
            startDate: Date?,
            endDate: Date?,
            pairRowDetails: PairRowDetails?,
            sharedNow: Shared<Date>
        ) {
            self.pairRowDetails = pairRowDetails
            self._sharedNow = sharedNow

            self.scheduleList = ScheduleListFeature.State(
                scheduleType: .exams,
                days: [],
                loading: .never,
                startDate: startDate,
                endDate: endDate
            )

            @Dependency(\.calendar) var calendar

            self.loadDays(
                exams: exams,
                calendar: calendar,
                now: sharedNow.wrappedValue
            )
        }
    }

    public enum Action {
        case scheduleList(ScheduleListFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.scheduleList, action: \.scheduleList) {
            ScheduleListFeature()
        }
    }
}
