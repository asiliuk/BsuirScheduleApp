import SwiftUI

public struct ScheduleGridSectionPlaceholder: View {
    let titleLength: Int
    let numberOfPairs: Int

    public init(titleLength: Int, numberOfPairs: Int) {
        self.titleLength = titleLength
        self.numberOfPairs = numberOfPairs
    }

    public var body: some View {
        Section {
            ForEach(0..<numberOfPairs, id: \.self) { _ in
                PairPlaceholder()
            }
        } header: {
            ScheduleDateTitle(
                date: String(repeating: "-", count: titleLength),
                relativeDate: nil,
                isToday: false
            )
        }
        .listRowSeparator(.hidden)
        .redacted(reason: .placeholder)
    }
}
