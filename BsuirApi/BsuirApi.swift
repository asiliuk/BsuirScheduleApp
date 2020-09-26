import Foundation

extension RequestsManager {

    public static func bsuir(session: URLSession = .cached, logger: Logger? = nil) -> RequestsManager {
        return RequestsManager(base: "https://journal.bsuir.by/api/v1", session: session, decoder: decoder, logger: logger)
    }
}

extension URLSession {
    public static let cached: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }()
}

public enum BsuirTargets {

    public enum Agent {
        case groupName(String)
        case groupID(Int)
    }

    public struct Schedule: Target {

        public typealias Value = Group.Schedule

        public let path = "/studentGroup/schedule"
        public let parameters: [String: String]

        public init(agent: Agent) {
            parameters = agent.parameters
        }
    }

    public struct EmployeeSchedule: Target {

        public typealias Value = Employee.Schedule

        public let path = "/portal/employeeSchedule"
        public let parameters: [String: String]

        public init(id: Int) {
            parameters = ["employeeId": String(id)]
        }
    }

    public struct FindEmployee: Target {

        public typealias Value = [Employee]

        public let path = "/portal/employeeSchedule/employee"
        public let parameters: [String: String]

        init(query: String) {
            parameters = ["employeeFio": query]
        }
    }

    public struct LastUpdate: Target {

        public struct Value: Decodable {
            public let lastUpdateDate: Date
        }

        public let path = "/studentGroup/lastUpdateDate"
        public let parameters: [String: String]

        public init(agent: Agent) {
            parameters = agent.parameters
        }
    }

    public struct Groups: Target {
        public typealias Value = [Group]
        public let path = "/groups"
        public init() {}
    }

    public struct Employees: Target {
        public typealias Value = [Employee]
        public let path = "/employees"
        public init() {}
    }

    public struct Week: Target {
        public typealias Value = Int
        public let path = "/portal/schedule/week"
        public init() {}
    }
}

private extension RequestsManager {

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = .minsk
        return formatter
    }()
}

private extension BsuirTargets.Agent {

    var parameters: [String: String] {
        switch self {
        case .groupID(let id): return ["id": String(id)]
        case .groupName(let name): return ["studentGroup": name]
        }
    }
}
