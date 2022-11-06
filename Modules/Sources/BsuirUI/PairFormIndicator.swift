import SwiftUI

struct PairFormIndicator: View {
    var form: PairViewForm
    var progress: Double
    var differentiateWithoutColor: Bool
    @ScaledMetric(relativeTo: .body) private var formIndicatorWidth: CGFloat = 8
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            if differentiateWithoutColor {
                ShapePairFormIndicator(
                    form: form,
                    progress: progress,
                    proxy: proxy,
                    passedOpacity: passedOpacity
                )
            } else {
                PillPairFormIndicator(
                    progress: progress,
                    proxy: proxy,
                    passedOpacity: passedOpacity
                )
            }
        }
        .foregroundColor(PairColorService.shared.getColor(for: form).color)
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

private struct ShapePairFormIndicator: View {
    var form: PairViewForm
    var progress: Double
    var proxy: GeometryProxy
    var passedOpacity: Double

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<numberOfViews, id: \.self) { index in
                form.shape
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .opacity(index < passedIndex ? passedOpacity : 1)
            }
        }
    }

    private var passedIndex: Int {
        guard progress > 0 else { return 0 }
        return Int(Double(numberOfViews) * max(progress, minProgress))
    }

    private var minProgress: Double {
        guard numberOfViews > 0 else { return 1 }
        return 1.0 / Double(numberOfViews)
    }

    private var numberOfViews: Int {
        Int((proxy.size.height * 0.95) / proxy.size.width)
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
            PairFormIndicator(form: .lecture, progress: 0, differentiateWithoutColor: differentiateWithoutColor)
            PairFormIndicator(form: .lab, progress: 0.3, differentiateWithoutColor: differentiateWithoutColor)
            PairFormIndicator(form: .practice, progress: 0.5, differentiateWithoutColor: differentiateWithoutColor)
            PairFormIndicator(form: .exam, progress: 1, differentiateWithoutColor: differentiateWithoutColor)
            PairFormIndicator(form: .unknown, progress: 0.9, differentiateWithoutColor: differentiateWithoutColor)
        }
    }
}
