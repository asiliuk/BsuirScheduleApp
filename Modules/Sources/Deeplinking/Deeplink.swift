import Foundation
import URLRouting

public enum PremiumClubDeeplinkSource: String {
    case pin = "pin"
    case appIcon = "app_icon"
}

public enum Deeplink {
    case groups
    case group(name: String)
    case lecturers
    case lector(id: Int)
    case settings
    case premiumClub(source: PremiumClubDeeplinkSource? = nil)
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

private let bsuirScheduleScheme = Scheme("bsuir-schedule")
