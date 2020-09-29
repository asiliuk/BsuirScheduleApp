import SwiftUI
import BsuirCore

public struct PairCell: View {
    var pair: PairView
    public init(
        from: String,
        to: String,
        subject: String,
        weeks: String? = nil,
        subgroup: String? = nil,
        auditory: String,
        note: String? = nil,
        form: PairView.Form,
        progress: PairProgress
    ) {
        self.pair = PairView(
            from: from,
            to: to,
            subject: subject,
            weeks: weeks,
            subgroup: subgroup,
            auditory: auditory,
            note: note,
            form: form,
            progress: progress
        )
    }

    public var body: some View {
        pair
            .padding(.leading)
            .padding(.trailing, 4)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.secondarySystemBackground))
            )
    }
}

public struct PairView: View {
    public enum Form: CaseIterable {
        case lecture
        case practice
        case lab
        case exam
        case unknown
    }

    public enum Distribution {
        case vertical
        case horizontal
    }

    public var from: String
    public var to: String
    public var subject: String
    public var weeks: String?
    public var subgroup: String?
    public var auditory: String
    public var note: String?
    public var form: Form
    @ObservedObject public var progress: PairProgress
    public var distribution: Distribution
    public var isCompact: Bool
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    public init(
        from: String,
        to: String,
        subject: String,
        weeks: String? = nil,
        subgroup: String? = nil,
        auditory: String,
        note: String? = nil,
        form: Form,
        progress: PairProgress,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false
    ) {
        self.from = from
        self.to = to
        self.subject = subject
        self.weeks = weeks
        self.subgroup = subgroup
        self.auditory = auditory
        self.note = note
        self.form = form
        self.progress = progress
        self.distribution = distribution
        self.isCompact = isCompact
    }

    public var body: some View {
        HStack(spacing: 8) {

            switch (distribution, sizeCategory.isAccessibilityCategory) {
            case (.vertical, _), (.horizontal, true):
                PairFormIndicator(form: form, progress: progress.value, differentiateWithoutColor: differentiateWithoutColor)

                VStack(alignment: .leading) {
                    Text("\(from)-\(to)").font(.system(.footnote, design: .monospaced))
                    title
                    subtitle
                }
            case (.horizontal, false):
                VStack(alignment: .trailing) {
                    Text(from).font(.system(isCompact ? .footnote : .callout, design: .monospaced))
                    Text(to).font(.system(isCompact ? .caption2 : .footnote, design: .monospaced))
                }

                PairFormIndicator(form: form, progress: progress.value, differentiateWithoutColor: differentiateWithoutColor)

                VStack(alignment: .leading) {
                    title
                    subtitle
                }
            }

            Spacer(minLength: 0).layoutPriority(-1)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibility(label: accessibilityDescription(
            "\(subject) \(Text(form.name))",
            progress.isNow ? "Идет сейчас" : nil,
            "с \(from) по \(to)",
            weeks.map { "Недели: \($0)" },
            subgroup.map { "Подгруппа: \($0)" },
            "аудитория: \(auditory)",
            note.map { "\($0)" }
        ))
    }

    private var title: some View {
        combineTexts(
            subjectText,
            periodityText?.fontWeight(.light),
            separator: " "
        )
        .font(isCompact ? .subheadline : .headline)
        .lineLimit(2)
    }

    private var subtitle: some View {
        Group {
            if isCompact {
                combineTexts(auditoryText, noteText).lineLimit(distribution == .vertical ? 2 : 1)
            } else {
                VStack(alignment: .leading) {
                    auditoryText
                    noteText
                }
            }
        }
        .opacity(0.8)
        .font(isCompact ? .footnote : .callout)
    }

    private var subjectText: Text {
        Text(subject).bold()
    }

    private var periodityText: Text? {
        combineTexts(
            weeks.map { Text("\(Image(systemName: "calendar"))\($0)") },
            subgroup.map { Text("\(Image(systemName: "person"))\($0)") },
            separator: " "
        )?.foregroundColor(Color.primary.opacity(0.8))
    }

    private var auditoryText: Text {
        Text(auditory)
    }

    private var noteText: Text? {
        note.map { Text($0) }
    }
}

extension PairCell {
    public init(pair: PairViewModel) {
        self.pair = PairView(pair: pair)
    }
}

extension PairView {
    public init(pair: PairViewModel, distribution: Distribution = .horizontal, isCompact: Bool = false) {
        self.init(
            from: pair.from,
            to: pair.to,
            subject: pair.subject,
            weeks: pair.weeks,
            subgroup: pair.subgroup,
            auditory: pair.auditory,
            note: pair.note,
            form: PairView.Form(pair.form),
            progress: pair.progress,
            distribution: distribution,
            isCompact: isCompact
        )
    }
}

private extension PairView.Form {
    init(_ form: PairViewModel.Form) {
        switch form {
        case .exam: self = .exam
        case .lab: self = .lab
        case .lecture: self = .lecture
        case .practice: self = .practice
        case .unknown: self = .unknown
        }
    }
}

private extension PairProgress {
    var isNow: Bool {
        value > 0 && value < 1
    }
}

private struct PairFormIndicator: View {
    var form: PairView.Form
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
        .foregroundColor(form.color)
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
    var form: PairView.Form
    var progress: Double
    var proxy: GeometryProxy
    var passedOpacity: Double

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<numberOfViews, id: \.self) { index in
                Spacer(minLength: 0)
                form.shape
                    .apply(when: index < passedIndex) { $0.opacity(passedOpacity) }
                    .aspectRatio(contentMode: .fit)
                Spacer(minLength: 0)
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

extension PairView.Form {
    public var name: LocalizedStringKey {
        switch self {
        case .lecture: return "Лекция"
        case .lab: return "Лабораторная работа"
        case .practice: return "Практическая работа"
        case .exam: return "Экзамен"
        case .unknown: return "Неизвестно"
        }
    }

    public var color: Color {
        switch self {
        case .lecture: return .green
        case .practice: return .red
        case .lab: return .yellow
        case .exam: return .purple
        case .unknown: return .gray
        }
    }

    @ViewBuilder public var shape: some View {
        switch self {
        case .lecture: Circle()
        case .practice: Rectangle()
        case .lab: Image(systemName: "triangle.fill").resizable()
        case .exam: Image(systemName: "star.fill").resizable()
        case .unknown: Image(systemName: "rhombus.fill").resizable()
        }
    }
}

#if DEBUG
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

struct PairView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            pair
            mutating(pair) { $0.pair.distribution = .vertical; $0.pair.isCompact = true }
            mutating(pair) { $0.pair.isCompact = true }
            mutating(pair) { $0.pair.weeks = nil; $0.pair.subgroup = nil }
            pair.colorScheme(.dark)
            pair.environment(\.sizeCategory, .accessibilityMedium)
        }
        .previewLayout(.sizeThatFits)
        .background(Color.gray)
    }

    static let pair = PairCell(
        from: "10:00",
        to: "11:30",
        subject: "ОСиСП",
        weeks: "1,2",
        subgroup: "1",
        auditory: "101-1",
        note: "Пара проходит в подвале",
        form: .lab,
        progress: PairProgress(constant: 0)
    )
}
#endif
