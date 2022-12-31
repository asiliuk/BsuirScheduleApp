import Foundation
import SwiftUI

public enum AppIcon: Hashable {
    public enum Plain: CaseIterable, Hashable, Identifiable {
        public var id: Self { self }
        case standard
        case dark
        case nostalgia
    }

    public enum Symbol: CaseIterable, Hashable, Identifiable {
        public var id: Self { self }
        case resist
        case national
        case ukrainian
        case pride
    }

    case plain(Plain)
    case symbol(Symbol)
}

extension AppIcon {
    init?(name: String) {
        switch name {
        case "AppIcon": self = .plain(.standard)
        case "AppIconDark": self = .plain(.dark)
        case "AppIconNostalgia": self = .plain(.nostalgia)
        case "AppIconResist": self = .symbol(.resist)
        case "AppIconNational": self = .symbol(.national)
        case "AppIconUkrainian": self = .symbol(.ukrainian)
        case "AppIconPride": self = .symbol(.pride)
        default: return nil
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .plain(.standard): return "screen.settings.appIcon.icon.default.title"
        case .plain(.dark): return "screen.settings.appIcon.icon.dark.title"
        case .plain(.nostalgia): return "screen.settings.appIcon.icon.nostalgia.title"
        case .symbol(.resist): return "screen.settings.appIcon.icon.resist.title"
        case .symbol(.pride): return "screen.settings.appIcon.icon.pride.title"
        case .symbol(.national): return "screen.settings.appIcon.icon.belarusFlag.title"
        case .symbol(.ukrainian): return "screen.settings.appIcon.icon.ukrainianFlag.title"
        }
    }

    /// Name used to create UIImage for the app icon
    var imageName: String {
        iconName ?? "AppIcon"
    }

    /// Name used to set alternative app icon
    ///
    /// Should be `nil` for default app icon
    var iconName: String? {
        switch self {
        case .plain(.standard): return nil
        case .plain(.dark): return "AppIconDark"
        case .plain(.nostalgia): return "AppIconNostalgia"
        case .symbol(.resist): return "AppIconResist"
        case .symbol(.national): return "AppIconNational"
        case .symbol(.ukrainian): return "AppIconUkrainian"
        case .symbol(.pride): return "AppIconPride"
        }
    }
}
