import Foundation

/// Namespace for IIS Bsuir API targets
///
/// API documentation could be found [here](https://iis.bsuir.by/api)
public enum BsuirIISTargets {
    
    /// Get schedule of the group
    public struct GroupSchedule: Target {
        public typealias Value = Group.Schedule
        public let path = "/v1/schedule"
        public let parameters: [String: String]

        public init(groupNumber: String) {
            parameters = ["studentGroup": groupNumber]
        }
    }

    /// Get schedule of the employee
    public struct EmployeeSchedule: Target {
        public typealias Value = Employee.Schedule
        public let path: String

        public init(urlId: String) {
            path = "/v1/employees/schedule/\(urlId)"
        }
    }

    /// Get list of all groups
    public struct Groups: Target {
        public typealias Value = [Group]
        public let path = "/v1/student-groups"
        public init() {}
    }
    
    /// Get list of all employees
    public struct Employees: Target {
        public typealias Value = [Employee]
        public let path = "/v1/employees/all"
        public init() {}
    }

    
    /// Get number of current week
    public struct Week: Target {
        public typealias Value = Int
        public let path = "/v1/schedule/current-week"
        public init() {}
    }
}
