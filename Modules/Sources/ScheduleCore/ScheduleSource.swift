import Foundation
import BsuirApi
import CasePaths

@CasePathable
public enum ScheduleSource: Equatable, Codable {
    case group(name: String)
    case lector(Employee)
}

// MARK: - Checks

extension ScheduleSource {
    public var title: String {
        switch self {
        case .group(let name): name
        case .lector(let lector): lector.compactFio
        }
    }
    
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
