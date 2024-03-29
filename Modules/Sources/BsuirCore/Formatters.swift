import Foundation

extension FormatStyle where Self == Date.FormatStyle {
    public static var pairTime: Self {
        return .init(timeZone: .minsk)
            .hour(.twoDigits(amPM: .narrow))
            .minute(.twoDigits)
    }

    public static var pairDate: Self {
        return .dateTime
            .day()
            .month(.wide)
            .year()
    }

    public static var scheduleDay: Self {
        return .dateTime
            .weekday()
            .day()
            .month(.wide)
    }

    public static var examDay: Self {
        return .scheduleDay
            .year(.twoDigits)
    }

    public static var compactExamDay: Self {
        return Date.FormatStyle(date: .numeric, time: .omitted)
    }

    public static var widgetSmall: Self {
        return .dateTime
            .day()
            .weekday()
    }
    
    public static var widgetNormal: Self {
        return widgetSmall.month()
    }
}

extension FormatStyle where Self == Date.IntervalFormatStyle {
    public static var pairTime: Self {
        return .init(timeZone: .minsk)
            .hour(.defaultDigits(amPM: .narrow))
            .minute()
    }

    public static var scheduleDates: Self {
        return .interval
            .day()
            .month()
            .year()
    }
}

extension Collection where Element == String {
    public func formatted(
        visibleCount: Int,
        placeholder: (Int) -> String
    ) -> String {
        let visible = prefix(visibleCount)
        let remaining = count - visibleCount
        guard remaining > 0 else { return visible.formatted() }
        return (visible + [placeholder(remaining)]).formatted()
    }
}
