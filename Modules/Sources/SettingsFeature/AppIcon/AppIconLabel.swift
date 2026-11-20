import Foundation
import UIKit
import BsuirCore
import BsuirUI
import ComposableArchitecture
import AppIcons

@Reducer
public struct AppIconLabel {
    @ObservableState
    public struct State {
        var supportsIconPicking: Bool {
            @Dependency(\.appIcons.supportsAlternateIcons) var supportsAlternateIcons
            return supportsAlternateIcons()
        }

        @SharedReader(.appIcon) var currentIcon
    }
}
