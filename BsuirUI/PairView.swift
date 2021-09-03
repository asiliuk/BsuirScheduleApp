import SwiftUI
import BsuirCore

public struct PairCell<Details: View>: View {
    var pair: PairView<Details>
    public init(
        from: String,
        to: String,
        subject: String,
        weeks: String? = nil,
        subgroup: String? = nil,
        auditory: String,
        note: String? = nil,
        form: PairViewForm,
        progress: PairProgress,
        details: Details
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
            progress: progress,
            details: details
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

public enum PairViewForm: CaseIterable {
    case lecture
    case practice
    case lab
    case exam
    case unknown
}

public struct PairView<Details: View>: View {
    public enum Distribution {
        case vertical
        case horizontal
    }

    public var from: String
    public var to: String
    public var subject: String?
    public var weeks: String?
    public var subgroup: String?
    public var auditory: String
    public var note: String?
    public var form: PairViewForm
    @ObservedObject public var progress: PairProgress
    public var distribution: Distribution
    public var isCompact: Bool
    public let details: Details
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    public init(
        from: String,
        to: String,
        subject: String?,
        weeks: String? = nil,
        subgroup: String? = nil,
        auditory: String,
        note: String? = nil,
        form: PairViewForm,
        progress: PairProgress,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false,
        details: Details
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
        self.details = details
    }

    public var body: some View {
        HStack(spacing: 8) {

            switch (distribution, sizeCategory.isAccessibilityCategory) {
            case (.vertical, _), (.horizontal, true):
                VStack(alignment: .leading) {
                    HStack(spacing: 8) {
                        PairFormIndicator(form: form, progress: progress.value, differentiateWithoutColor: differentiateWithoutColor)

                        VStack(alignment: .leading) {
                            Text("\(from)-\(to)").font(.system(.footnote, design: .monospaced))
                            title
                            subtitle
                        }

                        Spacer(minLength: 0).layoutPriority(-1)
                    }

                    if !isCompact { details }
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

                Spacer(minLength: 0).layoutPriority(-1)

                details
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibility(label: accessibilityDescription(
            subject.map { "\($0) \(Text(form.name))" },
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

    private var subjectText: Text? {
        subject.map { Text($0).bold() }
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
    public init(pair: PairViewModel, details: Details) {
        self.pair = PairView(pair: pair, details: details)
    }
}

public struct LecturerAvatars<Model>: View {
    let lecturers: [Model]
    let name: (Model) -> String
    let avatar: (Model) -> URL?
    let showDetails: (Model) -> Void
    @ScaledMetric(relativeTo: .body) private var overlap: CGFloat = 24
    @State private var isActionSheetShown = false

    public init(
        lecturers: [Model],
        name: @escaping (Model) -> String,
        avatar: @escaping (Model) -> URL?,
        showDetails: @escaping (Model) -> Void
    ) {
        self.lecturers = lecturers
        self.name = name
        self.avatar = avatar
        self.showDetails = showDetails
    }

    public var body: some View {
        if lecturers.isEmpty {
            EmptyView()
        } else {
            Menu {
                ForEach(lecturers.indices, id: \.self) {
                    let lecturer = lecturers[$0]
                    Button {
                        showDetails(lecturer)
                    } label: {
                        Text(name(lecturer))
                    }
                }
            } label: {
                HStack(spacing: -overlap) {
                    ForEach(lecturers.indices, id: \.self) {
                        Avatar(url: avatar(lecturers[$0]))
                    }
                }
            }
        }
    }
}

extension PairView {
    public init(
        pair: PairViewModel,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false,
        details: Details
    ) {
        self.init(
            from: pair.from,
            to: pair.to,
            subject: pair.subject,
            weeks: pair.weeks,
            subgroup: pair.subgroup,
            auditory: pair.auditory,
            note: pair.note,
            form: PairViewForm(pair.form),
            progress: pair.progress,
            distribution: distribution,
            isCompact: isCompact,
            details: details
        )
    }
}

extension PairView where Details == EmptyView {
    public init(
        pair: PairViewModel,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false
    ) {
        self.init(
            pair: pair,
            distribution: distribution,
            isCompact: isCompact,
            details: Details()
        )
    }
}

private extension PairViewForm {
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


extension PairViewForm {
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
        progress: PairProgress(constant: 0),
        details: LecturerAvatars(lecturers: ["", ""], name: { $0 }, avatar: { _ in nil }, showDetails: { _ in })
    )
}
#endif
