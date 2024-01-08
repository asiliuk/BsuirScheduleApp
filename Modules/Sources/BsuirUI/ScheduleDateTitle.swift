import SwiftUI

public struct ScheduleDateTitle: View {
    public enum Relativity {
        case passed
        case today
        case upcoming
    }

    public var date: String
    public var relativeDate: String?
    public var relativity: Relativity

    public init(date: String, relativeDate: String?, relativity: Relativity) {
        self.date = date
        self.relativeDate = relativeDate
        self.relativity = relativity
    }

    public var body: some View {
        ZStack {
            if let relativeDate = relativeDate {
                Text("\(Text(relativeDate).foregroundColor(relativity.accentColor)), \(date)")
            } else {
                Text(date)
            }
        }
        .font(relativity.font)
        .accessibility(addTraits: .isHeader)
        .foregroundStyle(relativity.color)
    }
}

private extension ScheduleDateTitle.Relativity {
    var color: Color {
        switch self {
        case .today, .upcoming: .primary
        case .passed: .secondary
        }
    }

    var font: Font {
        switch self {
        case .today, .upcoming: .headline
        case .passed: .subheadline
        }
    }

    var accentColor: Color {
        switch self {
        case .today: .blue
        case .passed, .upcoming: .red
        }
    }
}
