import SwiftUI
import BsuirCore
import BsuirApi
import ScheduleCore

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
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
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
    @EnvironmentObject private var pairFormDisplayService: PairFormDisplayService

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
                        pairForm

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

                pairForm

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

    private var pairForm: some View {
        PairFormIndicator(color: pairFormDisplayService.color(for: form).color, progress: progress.value)
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
        ZStack {
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
        if spellForm || differentiateWithoutColor || pairFormDisplayService.alwaysShowFormIcon {
            return Text("\(Image(systemName: form.symbolName))")
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
    public init(pair: PairViewModel, showWeeks: Bool, details: Details) {
        self.pair = PairView(pair: pair, showWeeks: showWeeks, details: details)
    }
}

extension PairView {
    public init(
        pair: PairViewModel,
        distribution: Distribution = .horizontal,
        isCompact: Bool = false,
        spellForm: Bool = false,
        showWeeks: Bool,
        details: Details
    ) {
        self.init(
            from: pair.from,
            to: pair.to,
            interval: pair.interval,
            subject: pair.subject,
            weeks: showWeeks ? pair.weeks : nil,
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
        spellForm: Bool = false,
        showWeeks: Bool
    ) {
        self.init(
            pair: pair,
            distribution: distribution,
            isCompact: isCompact,
            spellForm: spellForm,
            showWeeks: showWeeks,
            details: Details()
        )
    }
}

private extension PairProgress {
    var isNow: Bool {
        value > 0 && value < 1
    }
}

struct PairView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PairPlaceholder()

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
        .environmentObject(PairFormDisplayService(storage: .standard, widgetService: .noop))
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
