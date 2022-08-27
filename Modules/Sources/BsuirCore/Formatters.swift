//
//  Formatters.swift
//  
//
//  Created by Anton Siliuk on 20/08/2022.
//

import Foundation

extension FormatStyle where Self == Date.FormatStyle {
    public static var pairTime: Self {
        Date.FormatStyle()
            .hour(.twoDigits(amPM: .abbreviated))
            .minute(.twoDigits)
    }
    
    public static var scheduleDay: Self {
        Date.FormatStyle()
            .weekday()
            .day()
            .month(.wide)
    }
    
    public static var widgetSmall: Self {
        Date.FormatStyle()
            .day()
            .weekday()
    }
    
    public static var widgetNormal: Self {
        widgetSmall.month()
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
