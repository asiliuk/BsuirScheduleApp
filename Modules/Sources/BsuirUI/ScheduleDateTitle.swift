import SwiftUI

public struct ScheduleDateTitle: View {
    public enum Relativity {
        case passed
        case today
        case upcoming
    }

    public var title: String
    public var subtitle: String?
    public var relativeDate: String?
    public var relativity: Relativity

    public init(
        title: String,
        subtitle: String? = nil,
        relativeDate: String? = nil,
        relativity: Relativity
    ) {
        self.title = title
        self.subtitle = subtitle
        self.relativeDate = relativeDate
        self.relativity = relativity
    }

    public var body: some View {
        combineTexts(
            combineTexts(
                relativeDate.map { Text($0).foregroundColor(relativity.accentColor) },
                Text(title),
            ),
            subtitle.map { Text($0).font(.footnote).foregroundStyle(.secondary) },
            separator: " "
        )
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
