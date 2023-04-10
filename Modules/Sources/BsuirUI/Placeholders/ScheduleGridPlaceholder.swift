import SwiftUI

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
        .allowsHitTesting(false)
    }
}
