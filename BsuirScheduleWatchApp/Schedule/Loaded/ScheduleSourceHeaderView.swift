import SwiftUI
import ScheduleCore
import BsuirUI
import BsuirCore

struct ScheduleSourceHeaderView: View {
    let source: ScheduleDisplayType
    let start: Date?
    let end: Date?

    var body: some View {
        VStack(alignment: .leading) {
            combineTexts(
                Text(Image(systemName: source.imageName)),
                Text(source.title),
                separator: " "
            )

            if let start, let end {
                Text((start..<end).formatted(.scheduleDates))
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .listRowBackground(EmptyView())
    }
}
