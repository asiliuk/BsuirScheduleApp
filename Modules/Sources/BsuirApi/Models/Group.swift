//
//  Group.swift
//  Pods
//
//  Created by Anton Siliuk on 17.01.17.
//

import Foundation

public struct StudentGroup: Codable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let course: Int?
}

extension StudentGroup {
    public struct Schedule: Codable, Equatable {
        public let studentGroup: StudentGroup
        public let schedules: DaySchedule
        public let examSchedules: [Pair]
        
        private enum CodingKeys: String, CodingKey {
            case studentGroup = "studentGroupDto"
            case schedules
            case examSchedules = "exams"
        }
    }
}
