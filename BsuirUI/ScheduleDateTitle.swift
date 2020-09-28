import SwiftUI

public struct ScheduleDateTitle: View {
    public var date: String
    public var relativeDate: String?
    public var isToday: Bool

    public init(date: String, relativeDate: String?, isToday: Bool) {
        self.date = date
        self.relativeDate = relativeDate
        self.isToday = isToday
    }

    public var body: some View {
        Group {
                if let relativeDate = relativeDate {
                    Text("\(Text(relativeDate).foregroundColor(isToday ? .blue : .red)), \(date)")
                } else {
                    Text(date)
                }
            }
            .font(.headline)
            .accessibility(addTraits: .isHeader)
    }
}
