import Foundation
import URLRouting

/// IIS Bsuir API routes
///
/// API documentation could be found [here](https://iis.bsuir.by/api)
public enum IISRoute {
    case groupSchedule(groupName: String)
    case employeeSchedule(urlId: String)
    case studentGroups
    case employees
    case week
}

let iisRouter = OneOf {
    // GET /api/v1/schedule?studentGroup={groupNumber}
    Route(.case(IISRoute.groupSchedule(groupName:))) {
        Path { "v1"; "schedule" }
        Query { Field("studentGroup") }
    }

    // GET /v1/employees/schedule/{urlId}
    Route(.case(IISRoute.employeeSchedule(urlId:))) {
        Path { "v1"; "employees"; "schedule"; Rest().map(.string) }
    }

    // GET /v1/student-groups
    Route(.case(IISRoute.studentGroups)) {
        Path { "v1"; "student-groups" }
    }

    // GET /v1/employees/all
    Route(.case(IISRoute.employees)) {
        Path { "v1"; "employees";"all" }
    }

    // GET /v1/schedule/current-week
    Route(.case(IISRoute.week)) {
        Path { "v1"; "schedule"; "current-week" }
    }
}
