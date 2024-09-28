import Foundation
import SwiftUI
import PremiumClubFeature

extension SettingsFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        destination = nil
        selectedDestination = nil
    }

    public mutating func openPremiumClub(source: PremiumClubFeature.Source?) {
        selectedDestination = .premiumClub
        destination = .premiumClub(PremiumClubFeature.State(isModal: false, source: source))
    }
}
