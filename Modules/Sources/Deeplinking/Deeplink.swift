import Foundation
import URLRouting

public enum Deeplink {
    case groups
    case group(name: String)
    case lecturers
    case lector(id: Int)
}

public let deeplinkRouter = OneOf {
    //groups
    Route(.case(Deeplink.groups)) {
        bsuirSchedule
        Path { "groups" }
    }

    //groups/:name
    Route(.case(Deeplink.group(name:))) {
        bsuirSchedule

        Path {
            "groups"
            Rest().map(.string)
        }
    }

    //lecturers
    Route(.case(Deeplink.lecturers)) {
        bsuirSchedule
        Path { "lecturers" }
    }

    //lecturers/:id
    Route(.case(Deeplink.lector(id:))) {
        bsuirSchedule
        Path { "lecturers"; Digits() }
    }
}

private let bsuirSchedule = ParsePrint {
    Scheme("bsuir-schedule")
    Host("bsuirschedule.app")
}
