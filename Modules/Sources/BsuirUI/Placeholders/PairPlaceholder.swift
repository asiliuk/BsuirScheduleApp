import SwiftUI

public struct PairPlaceholder: View {

    public init() {}

    public var body: some View {
        PlaceholderView(speed: 0.07) { iteration in
            PairCell(
                from: "10:00",
                to: "11:30",
                interval: "",
                subject: placeholderText(for: iteration, from: 8, to: 22),
                weeks: nil,
                subgroup: nil,
                auditory: placeholderText(for: iteration, from: 1, to: 15),
                note: placeholderText(for: iteration, from: 4, to: 18),
                form: .unknown,
                progress: .init(constant: 0),
                details: EmptyView()
            )
        }
    }
}

public func placeholderText(for iteration: Int, from: Int, to: Int) -> String {
    String(repeating: "-", count: repeatCount(for: iteration, from: from, to: to))
}

public func repeatCount(for iteration: Int, from: Int, to: Int) -> Int {
    return iteration.quotientAndRemainder(dividingBy: (to - from)).remainder + from
}

struct PairPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PairPlaceholder()
        }
        .previewLayout(.sizeThatFits)
        .background(Color.gray)
        .environmentObject(PairFormColorService(storage: .standard, widgetService: .previewValue))
    }
}
