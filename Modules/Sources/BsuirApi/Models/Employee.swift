//
//  Employee.swift
//  Pods
//
//  Created by Anton Siliuk on 17.01.17.
//

import Foundation

public struct Employee: Codable, Equatable, Identifiable, Hashable {
    public let id: Int
    public let urlId: String
    
    public let firstName: String
    public let middleName: String?
    public let lastName: String
    
    public let photoLink: URL?
}

extension Employee {
    public struct Schedule: Codable, Equatable {
        public let employee: Employee
        public let schedules: WeekScheduleDto?
        public let examSchedules: [DaySchedule]?
        
        private enum CodingKeys: String, CodingKey {
            case employee = "employeeDto"
            case schedules
            case examSchedules = "exams"
        }
    }
}

extension Employee {
    public var fio: String {
        return [lastName, firstName, middleName]
            .compactMap { name in
                guard let name = name, !name.isEmpty else { return nil }
                return name
            }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
