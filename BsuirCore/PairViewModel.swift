import Foundation
import BsuirApi

public struct PairViewModel: Equatable {
    public enum Form: Equatable {
        case lecture
        case practice
        case lab
        case exam
        case unknown
    }

    public var from: String
    public var to: String
    public var form: Form
    public var subject: String
    public var auditory: String
    public var note: String?
    public var weeks: String?
    public var subgroup: String?
    public var progress: PairProgress

    public init(
        from: String,
        to: String,
        form: PairViewModel.Form,
        subject: String,
        auditory: String,
        note: String? = nil,
        weeks: String? = nil,
        subgroup: String? = nil,
        progress: PairProgress = .init(constant: 0)
    ) {
        self.from = from
        self.to = to
        self.form = form
        self.subject = subject
        self.auditory = auditory
        self.note = note
        self.weeks = weeks
        self.subgroup = subgroup
        self.progress = progress
    }

    private static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}

extension PairViewModel {
    public init(_ pair: BsuirApi.Pair, showWeeks: Bool = true, progress: PairProgress = .init(constant: 0)) {
        self.init(
            from: Self.timeFormatter.string(from: pair.startLessonTime.components) ?? "N/A",
            to: Self.timeFormatter.string(from: pair.endLessonTime.components) ?? "N/A",
            form: Form(pair.lessonType),
            subject: pair.subject,
            auditory: pair.auditory.joined(separator: ", "),
            note: pair.note,
            weeks: showWeeks ? pair.weekNumber.prettyName.capitalized : nil,
            subgroup: pair.numSubgroup == 0 ? nil : "\(pair.numSubgroup)",
            progress: progress
        )
    }
}

private extension PairViewModel.Form {

    init(_ form: BsuirApi.Pair.Form?) {
        switch form {
        case .lecture: self = .lecture
        case .practice: self = .practice
        case .lab: self = .lab
        case .exam: self = .exam
        case nil: self = .unknown
        }
    }
}

private extension BsuirApi.Pair.Time {
    var components: DateComponents {
        DateComponents(timeZone: timeZone, hour: hour, minute: minute)
    }
}

private extension BsuirApi.WeekNum {

    var prettyName: String {
        switch self {
        case []: return "-"
        case .always: return "♾"
        case let numbers: return numbers.name
        }
    }

    private var name: String {
        var result: [String] = []
        if contains(.first) { result.append("1") }
        if contains(.second) { result.append("2") }
        if contains(.third) { result.append("3") }
        if contains(.forth) { result.append("4") }
        return result.joined(separator: ",")
    }
}
