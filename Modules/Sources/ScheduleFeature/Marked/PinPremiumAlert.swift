import Foundation
import ComposableArchitecture

public enum PinPremiumAlertAction {
    case learnAboutPremiumClubButtonTapped
}

extension AlertState where Action == PinPremiumAlertAction {
    static let premiumLocked = AlertState {
        TextState("alert.premiumClub.pinnedSchedule.title")
    } actions: {
        ButtonState(action: .send(.learnAboutPremiumClubButtonTapped)) {
            TextState("alert.premiumClub.pinnedSchedule.button")
        }
        
        ButtonState(role: .cancel) {
            TextState("alert.premiumClub.pinnedSchedule.button")
        }
    } message: {
        TextState("alert.premiumClub.pinnedSchedule.message")
    }
}
