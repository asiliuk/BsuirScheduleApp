import SwiftUI

struct PairCell: View {
    enum Form {
        case lecture
        case practice
        case lab
        case exam
        case unknown
    }

    var from: String
    var to: String
    var subject: String
    var weeks: String?
    var note: String
    var form: Form
    @ObservedObject var progress: PairProgress
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        HStack() {

            if sizeCategory.isAccessibilityCategory {

                PairFormIndicator(form: form, progress: progress.value)

                VStack(alignment: .leading) {
                    Text("\(from)-\(to)").font(.system(.callout, design: .monospaced))
                    Text(subject).font(.headline).bold()
                    weeks.map { Text($0).font(.caption) }
                    Text(note).font(.caption)
                }
            } else {

                VStack(alignment: .trailing) {
                    Text(from).font(.system(.callout, design: .monospaced))
                    Text(to).font(.system(.footnote, design: .monospaced))
                }

                PairFormIndicator(form: form, progress: progress.value)

                VStack(alignment: .leading) {
                    HStack {
                        Text(subject).font(.headline).bold()
                        weeks.map { Text("(\($0))").font(.callout) }
                    }
                    Text(note).font(.callout)
                }
            }

            Spacer().layoutPriority(-1)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(.secondarySystemBackground))
        )
    }
}

private struct PairFormIndicator: View {
    var form: PairCell.Form
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

extension PairCell {
    init(pair: Day.Pair) {
        self.init(
            from: pair.from,
            to: pair.to,
            subject: pair.subject,
            weeks: pair.weeks,
            note: pair.note,
            form: Form(pair.form),
            progress: pair.progress
        )
    }
}

extension PairCell.Form {
    var color: Color {
        switch self {
        case .lecture: return .green
        case .practice: return .red
        case .lab: return .yellow
        case .exam: return .purple
        case .unknown: return .gray
        }
    }

    init(_ form: Day.Pair.Form) {
        switch form {
        case .exam: self = .exam
        case .lab: self = .lab
        case .lecture: self = .lecture
        case .practice: self = .practice
        case .unknown: self = .unknown
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
                note: "Пара проходит в подвале",
                form: .lab,
                progress: PairProgress(constant: 0)
            )

            PairCell(
                from: "9:00",
                to: "11:30",
                subject: "ОСиСП",
                weeks: "1,2",
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
