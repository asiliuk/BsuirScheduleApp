import Foundation
import URLRouting

public enum Deeplink {
    case groups
    case group(name: String)
    case lecturers
    case lector(id: Int)
    case about
}

public let deeplinkRouter = OneOf {
    //groups
    Route(.case(Deeplink.groups)) {
        bsuirScheduleScheme
        Path { "groups" }
    }

    //groups/:name
    Route(.case(Deeplink.group(name:))) {
        bsuirScheduleScheme
        Path { "groups"; Rest().map(.string) }
    }

    //lecturers
    Route(.case(Deeplink.lecturers)) {
        bsuirScheduleScheme
        Path { "lecturers" }
    }

    //lecturers/:id
    Route(.case(Deeplink.lector(id:))) {
        bsuirScheduleScheme
        Path { "lecturers"; Digits() }
    }

    //about
    Route(.case(Deeplink.about)) {
        bsuirScheduleScheme
        Path { "about" }
    }
}

private let bsuirScheduleScheme = Scheme("bsuir-schedule")
