import Foundation
import BsuirApi

public struct PairViewModel: Equatable, Identifiable {
    public enum Form: Equatable {
        case lecture
        case practice
        case lab
        case consultation
        case exam
        case unknown(String?)

        init(_ form: BsuirApi.Pair.Form?) {
            switch form {
            case .lecture: self = .lecture
            case .practice: self = .practice
            case .lab: self = .lab
            case .consultation: self = .consultation
            case .exam: self = .exam
            case let .unknown(value): self = .unknown(value)
            case nil: self = .unknown(nil)
            }
        }
    }

    public let id = UUID()
    public var from: String
    public var to: String
    public var interval: String
    public var form: Form
    public var subject: String?
    public var auditory: String?
    public var note: String?
    public var weeks: String?
    public var subgroup: String?
    public var progress: PairProgress
    public var lecturers: [Employee]
    public var groups: [String]

    public init(
        from: String,
        to: String,
        interval: String,
        form: PairViewModel.Form,
        subject: String?,
        auditory: String?,
        note: String? = nil,
        weeks: String? = nil,
        subgroup: String? = nil,
        progress: PairProgress = .init(constant: 0),
        lecturers: [Employee] = [],
        groups: [String] = []
    ) {
        self.from = from
        self.to = to
        self.interval = interval
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
        progress: PairProgress = .init(constant: 0)
    ) {
        self.init(
            from: Self.time(from: start),
            to: Self.time(from: end),
            interval: Self.interval(from: start, to: end),
            form: Form(pair.lessonType),
            subject: Self.title(from: pair),
            auditory: Self.details(from: pair),
            note: Self.note(from: pair),
            weeks: Self.weeks(from: pair.weekNumber),
            subgroup: Self.subgroup(from: pair.subgroup),
            progress: progress,
            lecturers: pair.employees,
            groups: pair.studentGroups.map(\.name)
        )
    }
}

private extension PairViewModel {
    
    static func interval(from fromDate: Date?, to toDate: Date?) -> String {
        guard let fromDate = fromDate else {
            return time(from: toDate)
        }
        
        guard let toDate = toDate else {
            return time(from: fromDate)
        }
        
        return (fromDate..<toDate).formatted(.pairTime)
    }
    
    static func time(from date: Date?) -> String {
        date?.formatted(.pairTime) ?? "N/A"
    }
    
    static func title(from pair: BsuirApi.Pair) -> String? {
        pair.subject ?? (pair.announcement ? String(localized: "view.pairView.announcement.title") : nil)
    }
    
    static func details(from pair: BsuirApi.Pair) -> String? {
        Self.auditory(from: pair.auditories)
    }
    
    static func note(from pair: BsuirApi.Pair) -> String? {
        return [pair.note?.trimmingCharacters(in: .whitespacesAndNewlines), announcement(pair: pair)]
            .compactMap { $0 }
            .joined(separator: "\n")
            .nilOnEmpty()
    }
    
    static func auditory(from auditories: [String]) -> String? {
        guard !auditories.isEmpty else {
            return nil
        }
        
        return auditories
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .joined(separator: ", ")
            .nilOnEmpty()
    }
    
    static func announcement(pair: BsuirApi.Pair) -> String? {
        guard pair.announcement else {
            return nil
        }
        
        return [pair.announcementStart, pair.announcementEnd]
            .compactMap { $0 }
            .joined(separator: " - ")
            .nilOnEmpty()
    }
    
    static func weeks(from weekNumber: WeekNum) -> String? {
        weekNumber.prettyName?.capitalized
    }
    
    static func subgroup(from subgroup: Int) -> String? {
        subgroup == 0 ? nil : "\(subgroup)"
    }
}

extension PairViewModel {
    public init(pair: WeekSchedule.ScheduleElement.Pair, progress: PairProgress) {
        self.init(
            start: pair.start,
            end: pair.end,
            pair: pair.base,
            progress: progress
        )
    }
    
    public init(pair: WeekSchedule.ScheduleElement.Pair) {
        self.init(
            start: pair.start,
            end: pair.end,
            pair: pair.base,
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
