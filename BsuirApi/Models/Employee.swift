//
//  Employee.swift
//  Pods
//
//  Created by Anton Siliuk on 17.01.17.
//

import Foundation

public struct Employee: Codable, Equatable {

    public let id: Int
    public let calendarID: String?

    public let firstName: String
    public let middleName: String
    public let lastName: String
    
    public let photoLink: URL?

    public struct Schedule : Codable, Equatable {
        public let employee: Employee
        public let schedules: [DaySchedule]?
        public let examSchedules: [DaySchedule]?
    }

    @NonEmpty public var academicDepartment: [String]
}
