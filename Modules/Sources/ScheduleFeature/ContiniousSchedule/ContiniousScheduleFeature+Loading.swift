import Foundation
import IdentifiedCollections
import ScheduleCore

extension ContinuousScheduleFeature {
    func clipSchedule(upTo clippingDate: Date, state: inout State) {
        // Find index of a day who's date is today or in the future
        guard let firstScheduleDayIndex = state.scheduleList.days.firstIndex(where: { state in
            guard case .continuousDate(let date, _) = state.dayDate else { return false }
            return calendar.isDate(date, inSameDayAs: clippingDate) || date > clippingDate
        }) else { return }

        // Remove all days that have passed
        state.scheduleList.days.removeFirst(firstScheduleDayIndex)

        // Load more schedule if clipping almost all
        if state.scheduleList.days.count <= 4 {
            state.load(count: 10, calendar: calendar, universityCalendar: universityCalendar, now: now)
        }
    }
}

extension ContinuousScheduleFeature.State {
    mutating func load(count: Int, calendar: Calendar, universityCalendar: Calendar, now: Date) {
        guard
            let weekSchedule = weekSchedule,
            let offset = offset,
            let start = calendar.date(byAdding: .day, value: 1, to: offset)
        else { return }

        let days = Array(
            weekSchedule.schedule(
                starting: start,
                now: now,
                calendar: calendar,
                universityCalendar: universityCalendar
            ).prefix(count)
        )
        scheduleList.loading = (days.count < count) ? .finished : .loadMore

        self.offset = days.last?.date
        var newDays = days.map { element in
            DaySectionFeature.State(
                element: element,
                pairRowDetails: pairRowDetails
            )
        }

        // Make sure newly aded sections has pairs filtered out by subgroup
        newDays.filter(keepingSubgroup: keepingSubgroup)

        scheduleList.days.append(contentsOf: newDays)
    }
}

// MARK: - DaySectionFeature

private extension DaySectionFeature.State {
    init(
        element: WeekSchedule.ScheduleElement,
        pairRowDetails: PairRowDetails?
    ) {
        self.init(
            dayDate: .continuousDate(element.date, weekNumber: element.weekNumber),
            pairs: element.pairs.map { pair in
                PairViewModel(
                    start: pair.start,
                    end: pair.end,
                    pair: pair.base,
                    progress: .updating(start: pair.start, end: pair.end)
                )
            },
            pairRowDetails: pairRowDetails,
            pairRowDay: .date(element.date)
        )
    }
}
