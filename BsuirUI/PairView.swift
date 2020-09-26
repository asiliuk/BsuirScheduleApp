import SwiftUI

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
                PairFormIndicator(form: form, progress: progress.value)

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

                PairFormIndicator(form: form, progress: progress.value)

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

private extension PairProgress {
    var isNow: Bool {
        value > 0 && value < 1
    }
}

private struct PairFormIndicator: View {
    var form: PairView.Form
    var progress: Double
    @ScaledMetric(relativeTo: .body) private var formIndicatorWidth: CGFloat = 8
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Capsule()
                    .opacity(colorScheme == .dark ? 0.5 : 0.3)

                Capsule()
                    .frame(height: progressHeight(proxy: proxy))
            }
        }
        .foregroundColor(form.color)
        .frame(width: formIndicatorWidth)
    }

    private func progressHeight(proxy: GeometryProxy) -> CGFloat {
        let height = proxy.size.height
        guard progress > 0 else { return height }
        guard progress < 1 else { return 0 }
        return max(height * CGFloat(1 - progress), formIndicatorWidth)
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
}

#if DEBUG
struct PairFormIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack {
                PairFormIndicator(form: .lecture, progress: 0.95)
                PairFormIndicator(form: .lab, progress: 0.3)
                PairFormIndicator(form: .practice, progress: 0.3)
                PairFormIndicator(form: .exam, progress: 0.3)
            }

            HStack {
                PairFormIndicator(form: .lecture, progress: 0.3)
                PairFormIndicator(form: .lab, progress: 0.3)
                PairFormIndicator(form: .practice, progress: 0.3)
                PairFormIndicator(form: .exam, progress: 0.3)
            }
            .background(Color.black)
            .colorScheme(.dark)
        }
        .frame(height: 50)
        .previewLayout(.sizeThatFits)
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
