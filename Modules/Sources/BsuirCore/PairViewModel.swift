import Foundation
import BsuirApi

public struct PairViewModel: Equatable, Identifiable {
    public enum Form: Equatable {
        case lecture
        case practice
        case lab
        case exam
        case unknown
    }

    public let id = UUID()
    public var from: String
    public var to: String
    public var form: Form
    public var subject: String?
    public var auditory: String
    public var note: String?
    public var weeks: String?
    public var subgroup: String?
    public var progress: PairProgress
    public var lecturers: [Employee]
    public var groups: [String]

    public init(
        from: String,
        to: String,
        form: PairViewModel.Form,
        subject: String?,
        auditory: String,
        note: String? = nil,
        weeks: String? = nil,
        subgroup: String? = nil,
        progress: PairProgress = .init(constant: 0),
        lecturers: [Employee] = [],
        groups: [String] = []
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
        self.lecturers = lecturers
        self.groups = groups
    }
}

extension PairViewModel {
    public init(
        start: Date?,
        end: Date?,
        pair: BsuirApi.Pair,
        showWeeks: Bool = true,
        progress: PairProgress = .init(constant: 0)
    ) {
        self.init(
            from: start?.formatted(.pairTime) ?? "N/A",
            to: end?.formatted(.pairTime) ?? "N/A",
            form: Form(pair.lessonType),
            subject: pair.subject,
            auditory: pair.auditories
                .map { $0.trimmingCharacters(in: .punctuationCharacters) }
                .joined(separator: ", "),
            note: pair.note,
            weeks: showWeeks ? pair.weekNumber.prettyName?.capitalized : nil,
            subgroup: pair.subgroup == 0 ? nil : "\(pair.subgroup)",
            progress: progress,
            lecturers: pair.employees,
            groups: pair.studentGroups.map(\.name)
        )
    }
}

extension PairViewModel {
    public init(pair: WeekSchedule.ScheduleElement.Pair, progress: PairProgress) {
        self.init(
            start: pair.start,
            end: pair.end,
            pair: pair.base,
            showWeeks: false,
            progress: progress
        )
    }
    
    public init(pair: WeekSchedule.ScheduleElement.Pair) {
        self.init(
            start: pair.start,
            end: pair.end,
            pair: pair.base,
            showWeeks: false,
            progress: PairProgress(from: pair.start, to: pair.end)
        )
    }
}

private extension PairProgress {
    convenience init(from: Date, to: Date) {
        self.init(
            Timer
                .publish(every: 60, on: .main, in: .default)
                .autoconnect()
                .prepend(Date())
                .map { Self.progress(at: $0, from: from, to: to) }
                .eraseToAnyPublisher()
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
        case .unknown, nil: self = .unknown
        }
    }
}

private extension BsuirApi.Pair.Time {
    var components: DateComponents {
        DateComponents(timeZone: timeZone, hour: hour, minute: minute)
    }
}

private extension BsuirApi.WeekNum {

    var prettyName: String? {
        switch self {
        case []: return nil
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
