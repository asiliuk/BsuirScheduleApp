import Foundation
import ComposableArchitecture

public enum PinPremiumAlertAction: Equatable {
    case learnAboutPremiumClubButtonTapped
}

extension AlertState where Action == PinPremiumAlertAction {
    static let premiumLocked = AlertState(
        title: TextState("alert.premiumClub.pinnedSchedule.title"),
        message: TextState("alert.premiumClub.pinnedSchedule.message"),
        buttons: [
            .default(
                TextState("alert.premiumClub.pinnedSchedule.button"),
                action: .send(.learnAboutPremiumClubButtonTapped)
            ),
            .cancel(TextState("alert.premiumClub.pinnedSchedule.cancel"))
        ]
    )
}
