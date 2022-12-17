import SwiftUI
import BsuirUI

public struct ScheduleGridPlaceholder: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            ScheduleGridSectionPlaceholder(
                titleLength: 12,
                numberOfPairs: 3
            )

            ScheduleGridSectionPlaceholder(
                titleLength: 16,
                numberOfPairs: 2
            )

            Spacer()
        }
        .padding()
        .redacted(reason: .placeholder)
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
            Text(String(repeating: "A", count: titleLength)).padding(.top)
        }
    }
}
