//
//  Formatters.swift
//  
//
//  Created by Anton Siliuk on 20/08/2022.
//

import Foundation

extension FormatStyle where Self == Date.FormatStyle {
    public static var pairTime: Self {
        return .init(timeZone: .minsk)
            .hour(.twoDigits(amPM: .narrow))
            .minute(.twoDigits)
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
        return .interval
            .hour(.defaultDigits(amPM: .narrow))
            .minute()
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
