import SwiftUI

public struct ShimmeringPairPlaceholder: View {
    public init() {}

    public var body: some View {
        PairCell(
            from: "10:00",
            to: "11:30",
            interval: "10:00 - 11:30",
            subject: placeholderText(length: 20),
            weeks: nil,
            subgroup: nil,
            auditory: placeholderText(length: 12),
            note: placeholderText(length: 16),
            form: .unknown,
            progress: .init(constant: 0),
            details: EmptyView()
        )
        .shimmeringPlaceholder()
        .environmentObject(PairFormDisplayService.noop)
    }
}

public func placeholderText(length: Int) -> String {
    String(repeating: "-", count: length)
}

#Preview {
    ShimmeringPairPlaceholder()
        .environmentObject(PairFormDisplayService.noop)
}
