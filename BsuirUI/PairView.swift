import SwiftUI

public struct PairCell: View {
    let pair: PairView
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
            .padding(.horizontal)
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

    public var from: String
    public var to: String
    public var subject: String
    public var weeks: String?
    public var subgroup: String?
    public var auditory: String
    public var note: String?
    public var form: Form
    @ObservedObject public var progress: PairProgress
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
        progress: PairProgress
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
    }

    public var body: some View {
        HStack(spacing: 8) {

            if sizeCategory.isAccessibilityCategory {

                PairFormIndicator(form: form, progress: progress.value)

                VStack(alignment: .leading) {
                    Text("\(from)-\(to)").font(.system(.callout, design: .monospaced))
                    Text(subject).font(.headline).bold()
                    Group {
                        periodityView
                        Text(auditory)
                        note.map { Text($0) }
                    }
                    .opacity(0.8)
                    .font(Font.caption2)
                }
            } else {

                VStack(alignment: .trailing) {
                    Text(from).font(.system(.callout, design: .monospaced))
                    Text(to).font(.system(.footnote, design: .monospaced))
                }

                PairFormIndicator(form: form, progress: progress.value)

                VStack(alignment: .leading) {
                    HStack(spacing: 6) {
                        Text(subject).font(.headline).bold()
                        periodityView.opacity(0.8)
                    }
                    Text(auditory).opacity(0.8)
                    note.map { Text($0).fontWeight(.light) }.opacity(0.8)
                }
                .font(.callout)
            }
            Spacer().layoutPriority(-1)
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

    private var periodityView: some View {
        HStack(spacing: 4) {
            weeks.map { Text("\(Image(systemName: "calendar"))\($0)") }
            subgroup.map { Text("\(Image(systemName: "person"))\($0)") }
        }
    }
}

private func accessibilityDescription(_ tokens: LocalizedStringKey?..., separator: String = ", ") -> Text {
    let nonEmptyTokens = tokens.compactMap { $0 }
    let initialInterpolation = LocalizedStringKey.StringInterpolation(
        literalCapacity: nonEmptyTokens.count * separator.count,
        interpolationCount: nonEmptyTokens.count
    )

    let interpolation = nonEmptyTokens.reduce(into: initialInterpolation) { interpolation, token in
        interpolation.appendLiteral(separator)
        interpolation.appendInterpolation(Text(token))
    }

    return Text(LocalizedStringKey(stringInterpolation: interpolation))
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
            PairCell(
                from: "9:00",
                to: "11:30",
                subject: "ОСиСП",
                weeks: "1,2",
                subgroup: "1",
                auditory: "101-1",
                note: "Пара проходит в подвале",
                form: .lab,
                progress: PairProgress(constant: 0)
            )

            PairCell(
                from: "9:00",
                to: "11:30",
                subject: "ОСиСП",
                weeks: "1,2",
                subgroup: "1",
                auditory: "101-1",
                note: "Пара проходит в подвале",
                form: .lab,
                progress: PairProgress(constant: 0)
            )
            .colorScheme(.dark)

            PairCell(
                from: "9:00",
                to: "11:30",
                subject: "ОСиСП",
                weeks: "1,2",
                subgroup: "1",
                auditory: "101-1",
                note: "Пара проходит в подвале",
                form: .lab,
                progress: PairProgress(constant: 0)
            )
            .environment(\.sizeCategory, .accessibilityMedium)
        }
        .previewLayout(.sizeThatFits)
        .background(Color.gray)
    }
}
#endif
