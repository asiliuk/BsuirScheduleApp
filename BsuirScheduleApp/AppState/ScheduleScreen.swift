//
//  ScheduleScreen.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/7/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import BsuirApi
import Combine
import Foundation

final class ScheduleScreen: LoadableContent<[Day]> {

    let name: String

    init(name: String, request: AnyPublisher<[DaySchedule], RequestsManager.RequestError>) {
        self.name = name
        super.init(request.map { $0.map(Day.init) }.eraseToLoading())
    }
}

struct Day: Hashable, Equatable {

    struct Pair: Hashable, Equatable {

        enum Form {
            case lecture
            case practice
            case lab
            case exam
            case unknown
        }

        let from: String
        let to: String
        let form: Form
        let subject: String
        let note: String
        let weeks: String

        init(_ pair: BsuirApi.Pair) {
            self.from = Self.timeFormatter.string(from: pair.startLessonTime.components) ?? "N/A"
            self.to = Self.timeFormatter.string(from: pair.endLessonTime.components) ?? "N/A"
            self.form = Form(pair.lessonType)
            self.subject = pair.subject
            self.note = (pair.auditory.map(Optional.some) + [pair.note]).compactMap { $0 }.joined(separator: ", ")
            self.weeks = pair.weekNumber.prettyName.capitalized
        }

        private static let timeFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()
    }

    let title: String
    let pairs: [Pair]

    init(day: DaySchedule) {
        self.title = day.weekDay.title
        self.pairs = day.schedule.map(Pair.init)
    }
}

private extension Day.Pair.Form {

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
        case []: return "никогда"
        case .oddWeeks: return "нечетные"
        case .evenWeeks: return "четные"
        case .always: return "вчегда"
        case let numbers: return numbers.name
        }
    }

    private var name: String {
        var result: [String] = []
        if contains(.first) { result.append("первая") }
        if contains(.second) { result.append("вторая") }
        if contains(.third) { result.append("третья") }
        if contains(.forth) { result.append("четвертая") }
        return result.joined(separator: ", ")
    }
}

private extension DaySchedule.Day {

    var title: String {
        switch self {
        case let .date(date): return Self.formatter.string(from: date)
        case let .relative(weekDay): return weekDay.rawValue
        }
    }

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
