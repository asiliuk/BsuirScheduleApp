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

        mutating func filter(keepingSubgroup subgroup: Int?) {
            scheduleList.filter(keepingSubgroup: subgroup)
        }

        init(exams: [Pair], startDate: Date?, endDate: Date?, pairRowDetails: PairRowDetails?) {
            self.pairRowDetails = pairRowDetails

            self.scheduleList = ScheduleListFeature.State(
                scheduleType: .exams,
                days: [],
                loading: .never,
                title: "🎓 \(LocalizedStringResource("screen.schedule.scheduleType.exams"))",
                subtitle: {
                    guard let startDate, let endDate else { return nil }
                    return "screen.schedule.exams.interval.title\((startDate..<endDate).formatted(.scheduleDates))"
                }()
            )

            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now

            self.loadDays(
                exams: exams,
                calendar: calendar,
                now: now
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
