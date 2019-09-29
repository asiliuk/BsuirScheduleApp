//
//  AppState.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import Foundation
import BsuirApi
import Combine

enum ContentState<Value: Equatable>: Equatable {
    case loading
    case error
    case some(Value)

    var isLoading: Bool {
        switch self {
        case .loading: return true
        case .error, .some: return true
        }
    }

    var isEmpty: Bool { isLoading }

    var isError: Bool {
        switch self {
        case .error: return true
        case .loading, .some: return true
        }
    }

    var some: Value? {
        switch self {
        case let .some(value): return value
        case .loading, .error: return nil
        }
    }
}

final class AppState: ObservableObject {
    let requestManager: RequestsManager
    init(requestManager: RequestsManager) { self.requestManager = requestManager }
    private(set) lazy var allGroups = AllGroupsState(requestManager: requestManager)
    private(set) lazy var allLecturers = AllLecturersState(requestManager: requestManager)
}

final class AllGroupsState: ObservableObject {
    let requestManager: RequestsManager
    init(requestManager: RequestsManager) { self.requestManager = requestManager }

    struct MyGroup: Identifiable, Comparable {
        var id: Int { group.id }
        var name: String { group.name }

        static func < (lhs: MyGroup, rhs: MyGroup) -> Bool { lhs.name < rhs.name }

        fileprivate init(group: Group) { self.group = group }
        fileprivate let group: Group
    }

    @Published var groups: [MyGroup] = []

    func request() {
        print("requesting...")
        cancellable = requestManager
            .request(BsuirApi.Groups())
            .map { $0.map(MyGroup.init) }
            .replaceError(with: [])
            .map { $0.sorted() }
            .receive(on: RunLoop.main)
            .weekAssign(to: \.groups, on: self)
    }

    func state(for group: MyGroup) -> GroupState {
        return GroupState(group: group.group, requestManager: requestManager)
    }

    private var cancellable: AnyCancellable?
}

struct Day: Equatable {
    let title: String
    let pairs: [String]

    init(day: DaySchedule) {
        self.title = day.weekDay.title
        self.pairs = day.schedule.map { $0.subject }
    }
}

final class GroupState: ObservableObject {

    init(group: Group, requestManager: RequestsManager) {
        self.group = group
        self.requestManager = requestManager
    }

    var name: String { group.name }
    @Published var days: [Day] = []

    func request() {
        print("Requesting days...")
        cancellable = requestManager
            .request(BsuirApi.Schedule(agent: .groupID(group.id)))
            .map { $0.schedules.map(Day.init) }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .weekAssign(to: \.days, on: self)
    }

    private var cancellable: AnyCancellable?
    private let group: Group
    private let requestManager: RequestsManager
}

final class AllLecturersState: ObservableObject {

    struct Lecturer: Identifiable {
        var id: Int { employee.id }
        var fullName: String { employee.fio }

        fileprivate init(employee: Employee) { self.employee = employee }
        fileprivate let employee: Employee
    }

    @Published var lecturers: [Lecturer] = []

    init(requestManager: RequestsManager) { self.requestManager = requestManager }

    func request() {
        cancellable = requestManager
            .request(BsuirApi.Employees())
            .map { $0.map(Lecturer.init) }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .weekAssign(to: \.lecturers, on: self)
    }

    func state(for lecturer: Lecturer) -> LecturerState {
        let a = LecturerState(employee: lecturer.employee, requestManager: requestManager)
        cancellable2 = a.objectWillChange.sink {
            print("LecturerState will change")
        }
        return a
    }

    private var cancellable2: AnyCancellable?
    private var cancellable: AnyCancellable?
    private let requestManager: RequestsManager
}

final class LecturerState: ObservableObject {

    init(employee: Employee, requestManager: RequestsManager) {
        self.employee = employee
        self.requestManager = requestManager
    }

    var name: String { employee.fio }
    @Published var days: [Day] = []

    func request() {
        cancellable = requestManager
            .request(BsuirApi.EmployeeSchedule(id: employee.id))
            .map { dump($0); return $0.schedules?.map(Day.init) ?? [] }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .weekAssign(to: \.days, on: self)
    }

    private var cancellable: AnyCancellable?
    private let employee: Employee
    private let requestManager: RequestsManager
}

private extension Employee {

    var fio: String {
        return [lastName, firstName, middleName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
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

private extension Publisher where Failure == Never {

    func weekAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
        sink(receiveValue: { [weak root] in root?[keyPath: keyPath] = $0 })
    }
}
