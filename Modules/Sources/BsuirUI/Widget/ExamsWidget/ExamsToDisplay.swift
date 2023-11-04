import Foundation
import ScheduleCore

struct ExamsToDisplay {
    /// Slice of pair models to display. Date is present if it is first pair in corresponding day.
    let visible: ArraySlice<(date: Date?, pair: PairViewModel)>
    /// Slice of pair models to show as upcoming. Date is present if it is first pair in corresponding day.
    let upcomingInvisible: ArraySlice<(date: Date?, pair: PairViewModel)>

    init(days: [ExamsScheduleWidgetConfiguration.ExamDay], maxVisiblePairsCount: Int) {
        let pairs = days.flatMap { day in
            day.pairs.map { pair in
                let isFirstPairInDay = pair == day.pairs.first
                return (date: isFirstPairInDay ? day.date : nil, pair: pair)
            }
        }

        let splitIndex = pairs.index(
            pairs.startIndex,
            offsetBy: maxVisiblePairsCount,
            boundedBy: pairs.endIndex
        )

        self.visible = pairs[..<splitIndex]
        self.upcomingInvisible = pairs[splitIndex...]
    }
}
