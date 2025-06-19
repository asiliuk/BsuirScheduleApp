import Foundation
import UIKit
import BsuirCore
import BsuirUI
import ComposableArchitecture

@Reducer
public struct AppIconLabel {
    @ObservableState
    public struct State {
        var supportsIconPicking: Bool {
            @Dependency(\.application.supportsAlternateIcons) var supportsAlternateIcons
            return supportsAlternateIcons()
        }

        @SharedReader(.appIcon) var currentIcon
    }
}
