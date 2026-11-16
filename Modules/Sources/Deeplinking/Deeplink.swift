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

@CasePathable
public enum Deeplink {
    case pinned(displayType: ScheduleDeeplinkDisplayType? = nil)
    case groups
    case group(_ name: String, _ displayType: ScheduleDeeplinkDisplayType? = nil)
    case lecturers
    case lector(_ id: Int, _ displayType: ScheduleDeeplinkDisplayType? = nil)
    case settings
    case premiumClub(source: PremiumClubDeeplinkSource? = nil)
}

public let deeplinkRouter = OneOf {
    //pinned
    Route(.case(\Deeplink.Cases.pinned)) {
        bsuirScheduleScheme
        Path { "pinned" }
        scheduleDisplayType
    }

    //groups
    Route(.case(\Deeplink.Cases.groups)) {
        bsuirScheduleScheme
        Path { "groups" }
    }

    //groups/:name
    Route(.case(\Deeplink.Cases.group)) {
        bsuirScheduleScheme
        Path { "groups"; Rest().map(.string) }
        scheduleDisplayType
    }

    //lecturers
    Route(.case(\Deeplink.Cases.lecturers)) {
        bsuirScheduleScheme
        Path { "lecturers" }
    }

    //lecturers/:id
    Route(.case(\Deeplink.Cases.lector)) {
        bsuirScheduleScheme
        Path { "lecturers"; Digits() }
        scheduleDisplayType
    }

    //settings
    Route(.case(\Deeplink.Cases.settings)) {
        bsuirScheduleScheme
        Path { "settings" }
    }

    //premium_club?source=...
    Route(.case(\Deeplink.Cases.premiumClub)) {
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
