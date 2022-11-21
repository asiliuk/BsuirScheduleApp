import SwiftUI
import BsuirCore
import BsuirApi

public struct PairCell<Details: View>: View {
    var pair: PairView<Details>
    public init(
        from: String,
        to: String,
        interval: String,
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
            interval: interval,
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

public enum PairViewForm: String, CaseIterable {
    case lecture
    case practice
    case lab
    case exam
    case consultation
    case unknown
}

public struct PairView<Details: View>: View {
    public enum Distribution {
        case vertical
        case horizontal
    }

    public var from: String
    public var to: String
    public var interval: String
    public var subject: String?
    public var weeks: String?
    public var subgroup: String?
    public var auditory: String?
    public var note: String?
    public var form: PairViewForm
    @ObservedObject public var progress: PairProgress
    public var distribution: Distribution
    public var isCompact: Bool
    public var spellForm: Bool
    public let details: Details
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    public init(
        from: String,
        to: String,
        interval: String,
        subject: String?,
        weeks: String? = nil,
        subgroup: String? = nil,
        auditory: String?,
        note: String? = nil,
        form: PairViewForm,
        progress: PairProgress,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false,
        spellForm: Bool = false,
        details: Details
    ) {
        self.from = from
        self.to = to
        self.interval = interval
        self.subject = subject
        self.weeks = weeks
        self.subgroup = subgroup
        self.auditory = auditory
        self.note = note
        self.form = form
        self.progress = progress
        self.distribution = distribution
        self.isCompact = isCompact
        self.spellForm = spellForm
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
                            Text(interval).font(.system(.footnote, design: .monospaced))
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
            progress.isNow ? "view.pairView.accessibility.label" : nil,
            "view.pairView.accessibility.from.\(from).to.\(to)",
            weeks.map { "view.pairView.accessibility.weeks.\($0)" },
            subgroup.map { "view.pairView.accessibility.subgroup.\($0)" },
            auditory.map { "view.pairView.accessibility.auditory.\($0)" },
            note.map { "\($0)" }
        ))
    }

    private var title: some View {
        combineTexts(
            formText?.fontWeight(.light),
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
    
    private var formText: Text? {
        if spellForm || differentiateWithoutColor {
            return Text(form.shortName)
        } else {
            return nil
        }
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

    private var auditoryText: Text? {
        auditory.map { Text($0) }
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

extension PairView {
    public init(
        pair: PairViewModel,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false,
        spellForm: Bool = false,
        details: Details
    ) {
        self.init(
            from: pair.from,
            to: pair.to,
            interval: pair.interval,
            subject: pair.subject,
            weeks: pair.weeks,
            subgroup: pair.subgroup,
            auditory: pair.auditory,
            note: pair.note,
            form: PairViewForm(pair.form),
            progress: pair.progress,
            distribution: distribution,
            isCompact: isCompact,
            spellForm: spellForm,
            details: details
        )
    }
}

extension PairView where Details == EmptyView {
    public init(
        pair: PairViewModel,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false,
        spellForm: Bool = false
    ) {
        self.init(
            pair: pair,
            distribution: distribution,
            isCompact: isCompact,
            spellForm: spellForm,
            details: Details()
        )
    }
}

public extension PairViewForm {
    init(_ form: PairViewModel.Form) {
        switch form {
        case .exam: self = .exam
        case .consultation: self = .consultation
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
        case .lecture: return "view.pairView.form.name.lecture"
        case .lab: return "view.pairView.form.name.lab"
        case .practice: return "view.pairView.form.name.practice"
        case .consultation: return "view.pairView.form.name.consultation"
        case .exam: return "view.pairView.form.name.exam"
        case .unknown: return "view.pairView.form.name.unknown"
        }
    }
    
    public var shortName: LocalizedStringKey {
        switch self {
        case .lecture: return "view.pairView.form.name.short.lecture"
        case .lab: return "view.pairView.form.name.short.lab"
        case .practice: return "view.pairView.form.name.short.practice"
        case .consultation: return "view.pairView.form.name.short.consultation"
        case .exam: return "view.pairView.form.name.short.exam"
        case .unknown: return "view.pairView.form.name.short.unknown"
        }
    }

    @ViewBuilder public var shape: some View {
        switch self {
        case .lecture: Circle()
        case .practice: Rectangle()
        case .lab: Image(systemName: "triangle.fill").resizable()
        case .consultation: Image(systemName: "hexagon.fill").resizable()
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
                .previewDisplayName("Pair")
            
            mutating(pair) { $0.pair.isCompact = true }
                .previewDisplayName("Compact")
            
            mutating(pair) { $0.pair.distribution = .vertical; $0.pair.isCompact = true }
                .previewDisplayName("Vertical Compact")
            
            mutating(pair) { $0.pair.spellForm = true }
                .previewDisplayName("Spell Form")
            
            mutating(pair) { $0.pair.distribution = .vertical; $0.pair.isCompact = true; $0.pair.spellForm = true }
                .previewDisplayName("Vertical Compact Spell Form")
            
            mutating(pair) { $0.pair.weeks = nil; $0.pair.subgroup = nil }
                .previewDisplayName("No week No subgroup")
        }
        .previewLayout(.sizeThatFits)
        .background(Color.gray)
    }

    static let pair = PairCell(
        from: "10:00",
        to: "11:30",
        interval: "10:00-11:30",
        subject: "ОСиСП",
        weeks: "1,2",
        subgroup: "1",
        auditory: "101-1",
        note: "Пара проходит в подвале",
        form: .lab,
        progress: PairProgress(constant: 0),
        details: EmptyView()
    )
}
#endif
