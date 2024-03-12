import Foundation
import SwiftUI
import PremiumClubFeature

extension SettingsFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !path.isEmpty {
            return path = NavigationPath()
        }
    }

    public mutating func openPremiumClub(source: PremiumClubFeature.Source?) {
        reset()
        premiumClub.source = source
        path.append(SettingsFeatureDestination.premiumClub)
    }
}
