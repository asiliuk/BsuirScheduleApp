import Foundation
import URLRouting
import CasePaths

public enum PremiumClubDeeplinkSource: String {
    case pin = "pin"
    case appIcon = "app_icon"
}

public enum ScheduleDeeplinkDisplayType: String {
    case continuous
    case compact
    case exams
}

public enum Deeplink {
    case pinned(displayType: ScheduleDeeplinkDisplayType? = nil)
    case groups
    case group(name: String, displayType: ScheduleDeeplinkDisplayType? = nil)
    case lecturers
    case lector(id: Int, displayType: ScheduleDeeplinkDisplayType? = nil)
    case settings
    case premiumClub(source: PremiumClubDeeplinkSource? = nil)
}

public let deeplinkRouter = OneOf {
    //pinned
    Route(.case(Deeplink.pinned)) {
        bsuirScheduleScheme
        Path { "pinned" }
        scheduleDisplayType
    }

    //groups
    Route(.case(Deeplink.groups)) {
        bsuirScheduleScheme
        Path { "groups" }
    }

    //groups/:name
    Route(.case(Deeplink.group(name:displayType:))) {
        bsuirScheduleScheme
        Path { "groups"; Rest().map(.string) }
        scheduleDisplayType
    }

    //lecturers
    Route(.case(Deeplink.lecturers)) {
        bsuirScheduleScheme
        Path { "lecturers" }
    }

    //lecturers/:id
    Route(.case(Deeplink.lector(id:displayType:))) {
        bsuirScheduleScheme
        Path { "lecturers"; Digits() }
        scheduleDisplayType
    }

    //settings
    Route(.case(Deeplink.settings)) {
        bsuirScheduleScheme
        Path { "settings" }
    }

    //premium_club?source=...
    Route(.case(Deeplink.premiumClub)) {
        bsuirScheduleScheme
        Path { "premium_club" }
        Query {
            Optionally {
                Field("source", .string.representing(PremiumClubDeeplinkSource.self))
            }
        }
    }
}
private let scheduleDisplayType = Query {
    Optionally {
        Field("display_type", .string.representing(ScheduleDeeplinkDisplayType.self))
    }
}

private let bsuirScheduleScheme = Scheme("bsuir-schedule")
