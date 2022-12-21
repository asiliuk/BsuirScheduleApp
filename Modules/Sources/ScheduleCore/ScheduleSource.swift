import Foundation
import BsuirApi

public enum ScheduleSource: Equatable, Codable {
    case group(name: String)
    case lector(Employee)
}

// MARK: - Checks

extension ScheduleSource {
    public var groupName: String? {
        switch self {
        case .group(let name):
            return name
        case .lector:
            return nil
        }
    }

    public var lector: Employee? {
        switch self {
        case .lector(let lector):
            return lector
        case .group:
            return nil
        }
    }
}
