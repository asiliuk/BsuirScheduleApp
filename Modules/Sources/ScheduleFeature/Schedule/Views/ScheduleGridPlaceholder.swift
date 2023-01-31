import SwiftUI
import BsuirUI

public struct ScheduleGridPlaceholder: View {
    public init() {}

    public var body: some View {
        List {
            ScheduleGridSectionPlaceholder(
                titleLength: 12,
                numberOfPairs: 3
            )

            ScheduleGridSectionPlaceholder(
                titleLength: 16,
                numberOfPairs: 2
            )

            ScheduleGridSectionPlaceholder(
                titleLength: 14,
                numberOfPairs: 4
            )
        }
        .listStyle(.plain)
        .redacted(reason: .placeholder)
        .allowsHitTesting(false)
    }
}

struct ScheduleGridSectionPlaceholder: View {
    let titleLength: Int
    let numberOfPairs: Int

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<numberOfPairs, id: \.self) { _ in
                    PairPlaceholder()
                }
            }
        } header: {
            ScheduleDateTitle(
                date: String(repeating: "-", count: titleLength),
                relativeDate: nil,
                isToday: false
            )
        }
        .listRowSeparator(.hidden)
    }
}
