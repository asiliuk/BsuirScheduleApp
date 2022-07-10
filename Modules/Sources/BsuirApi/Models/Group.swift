//
//  Group.swift
//  Pods
//
//  Created by Anton Siliuk on 17.01.17.
//

import Foundation

public struct Group: Codable, Equatable {

    public let id: Int
    public let name: String
    public let calendarId: String?
    public let course: Int?
    public let facultyId: Int
    public let specialityDepartmentEducationFormId: Int

    public struct Schedule: Codable, Equatable {
        public let studentGroup: Group
        @NonEmpty public var schedules: [DaySchedule]
        @NonEmpty public var examSchedules: [DaySchedule]
    }
}
