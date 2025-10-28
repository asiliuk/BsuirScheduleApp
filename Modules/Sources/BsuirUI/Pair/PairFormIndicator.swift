import SwiftUI

struct PairFormIndicator: View {
    var color: Color
    var progress: Double
    @ScaledMetric(relativeTo: .body) private var formIndicatorWidth: CGFloat = 8
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.redactionReasons) var redactionReasons

    var body: some View {
        GeometryReader { proxy in
            PillPairFormIndicator(
                progress: progress,
                proxy: proxy,
                passedOpacity: passedOpacity
            )
        }
        .foregroundColor(redactionReasons.contains(.placeholder) ? .gray : color)
        .frame(width: formIndicatorWidth)
    }

    private var passedOpacity: Double {
        colorScheme == .dark ? 0.5 : 0.3
    }
}

private struct PillPairFormIndicator: View {
    var progress: Double
    var proxy: GeometryProxy
    var passedOpacity: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .opacity(passedOpacity)

            Capsule()
                .frame(height: progressHeight)
        }
    }

    private var progressHeight: CGFloat {
        let height = proxy.size.height
        guard progress > 0 else { return height }
        guard progress < 1 else { return 0 }
        return max(height * CGFloat(1 - progress), proxy.size.width)
    }
}

struct PairFormIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            indicators()

            indicators(differentiateWithoutColor: true)

            indicators()
                .background(Color.black)
                .colorScheme(.dark)

            indicators(differentiateWithoutColor: true)
                .background(Color.black)
                .colorScheme(.dark)
        }
        .frame(height: 50)
        .previewLayout(.sizeThatFits)
    }

    private static func indicators(differentiateWithoutColor: Bool = false) -> some View {
        HStack {
            PairFormIndicator(color: .green, progress: 0)
            PairFormIndicator(color: .yellow, progress: 0.3)
            PairFormIndicator(color: .red, progress: 0.5)
            PairFormIndicator(color: .purple, progress: 1)
            PairFormIndicator(color: .gray, progress: 0.9)
        }
    }
}
