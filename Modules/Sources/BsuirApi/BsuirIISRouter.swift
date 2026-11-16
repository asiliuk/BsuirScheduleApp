import Foundation
import URLRouting
import CasePaths

/// IIS Bsuir API routes
///
/// API documentation could be found [here](https://iis.bsuir.by/api)
@CasePathable
enum IISRoute {
    case groupSchedule(groupName: String)
    case employeeSchedule(urlId: String)
    case studentGroups
    case employees
    case week
}

let iisRouter = OneOf {
    // GET /api/v1/schedule?studentGroup={groupNumber}
    Route(.case(\IISRoute.Cases.groupSchedule)) {
        Path { "v1"; "schedule" }
        Query { Field("studentGroup") }
    }

    // GET /v1/employees/schedule/{urlId}
    Route(.case(\IISRoute.Cases.employeeSchedule)) {
        Path { "v1"; "employees"; "schedule"; Rest().map(.string) }
    }

    // GET /v1/student-groups
    Route(.case(\IISRoute.Cases.studentGroups)) {
        Path { "v1"; "student-groups" }
    }

    // GET /v1/employees/all
    Route(.case(\IISRoute.Cases.employees)) {
        Path { "v1"; "employees";"all" }
    }

    // GET /v1/schedule/current-week
    Route(.case(\IISRoute.Cases.week)) {
        Path { "v1"; "schedule"; "current-week" }
    }
}
