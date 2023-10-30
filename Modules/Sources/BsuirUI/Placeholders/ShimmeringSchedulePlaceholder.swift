import SwiftUI

public struct ShimmeringSchedulePlaceholder: View {
    public init() {}

    public var body: some View {
        List {
            ShimmeringScheduleSectionPlaceholder(
                titleLength: 12,
                numberOfPairs: 3
            )

            ShimmeringScheduleSectionPlaceholder(
                titleLength: 16,
                numberOfPairs: 2
            )

            ShimmeringScheduleSectionPlaceholder(
                titleLength: 14,
                numberOfPairs: 4
            )
        }
        .listStyle(.plain)
        .allowsHitTesting(false)
    }
}

#Preview {
    ShimmeringSchedulePlaceholder()
        .environmentObject(PairFormDisplayService.noop)
}
