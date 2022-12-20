import Foundation
import BsuirApi

public enum ScheduleSource: Equatable, Codable {
    case group(name: String)
    case lector(Employee)
}

// MARK: - Checks

extension ScheduleSource {
    public func isGroup(named name: String) -> Bool {
        guard case .group(name) = self else {
            return false
        }

        return true
    }

    public func isLector(id: Int) -> Bool {
        guard case let .lector(lector) = self, lector.id == id else {
            return false
        }

        return true
    }
}
