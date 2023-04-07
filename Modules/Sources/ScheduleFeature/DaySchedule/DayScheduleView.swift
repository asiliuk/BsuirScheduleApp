import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture

struct DayScheduleView: View {
    struct ViewState: Equatable {
        var isOnTop: Bool
        var days: [ScheduleDayViewModel]
    }

    let store: StoreOf<DayScheduleFeature>

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
                    pairDetails: .nothing,
                    pairShowWeeks: true,
                    isOnTop: viewStore.binding(
                        get: \.isOnTop,
                        send: { .setIsOnTop($0) }
                    )
                )
            }
        }
    }
}

struct DayScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        DayScheduleView(
            store: .init(
                initialState: .init(schedule: DaySchedule(days: [
                    .monday: [
                        Pair(subject: "POIT"),
                        Pair(subject: "OSiSP")
                    ],
                    .sunday: [
                        Pair(subject: "POIT", weekNumber: .evenWeeks),
                        Pair(subject: "OSiSP", weekNumber: .oddWeeks)
                    ]
                ])),
                reducer: DayScheduleFeature()
            )
        )
    }
}
