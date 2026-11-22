import SwiftUI

public struct ShimmeringScheduleSectionPlaceholder: View {
    let titleLength: Int
    let numberOfPairs: Int

    public init(titleLength: Int, numberOfPairs: Int) {
        self.titleLength = titleLength
        self.numberOfPairs = numberOfPairs
    }

    public var body: some View {
        Section {
            ForEach(0..<numberOfPairs, id: \.self) { _ in
                ShimmeringPairPlaceholder()
            }
        } header: {
            ScheduleDateTitle(
                date: String(repeating: "-", count: titleLength),
                relativeDate: nil,
                relativity: .upcoming
            )
            .shimmeringPlaceholder()
        }
        #if os(iOS)
        .listRowSeparator(.hidden)
        #endif
    }
}

#Preview {
    ShimmeringScheduleSectionPlaceholder(titleLength: 10, numberOfPairs: 10)
}
