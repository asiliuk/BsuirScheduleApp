import BsuirApi

extension ApiClient {
    public func schedule(source: ScheduleSource, refresh: Bool) async throws -> ScheduleRequestResponse {
        switch source {
        case .group(let name):
            let response = try await groupSchedule(name, refresh)
            return ScheduleRequestResponse(response: response)
        case .lector(let employee):
            let response = try await lecturerSchedule(employee.urlId, refresh)
            return ScheduleRequestResponse(response: response)
        }
    }
}
