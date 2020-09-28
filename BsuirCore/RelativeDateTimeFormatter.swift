import Foundation

extension RelativeDateTimeFormatter {
    public static func relativeNameOnly() -> RelativeDateTimeFormatter {
        mutating(RelativeDateTimeFormatter()) {
            $0.locale = .by
            $0.dateTimeStyle = .named
            $0.formattingContext = .beginningOfSentence
        }
    }
}

extension RelativeDateTimeFormatter {
    public func relativeName(for date: Date, now: Date) -> String? {
        let components = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: date)
        )
        guard let day = components.day, -2...1 ~= day else { return nil }
        return localizedString(from: components)
    }
}
