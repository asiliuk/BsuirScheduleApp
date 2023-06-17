import SwiftUI

struct PairFormIndicator: View {
    var form: PairViewForm
    var progress: Double
    @ScaledMetric(relativeTo: .body) private var formIndicatorWidth: CGFloat = 8
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var pairFormColorService: PairFormColorService

    var body: some View {
        GeometryReader { proxy in
            PillPairFormIndicator(
                progress: progress,
                proxy: proxy,
                passedOpacity: passedOpacity
            )
        }
        .foregroundColor(pairFormColorService[form].color)
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
            PairFormIndicator(form: .lecture, progress: 0)
            PairFormIndicator(form: .lab, progress: 0.3)
            PairFormIndicator(form: .practice, progress: 0.5)
            PairFormIndicator(form: .exam, progress: 1)
            PairFormIndicator(form: .unknown, progress: 0.9)
        }
    }
}
