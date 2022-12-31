import Foundation
import SwiftUI

public enum AppIcon: CaseIterable, Equatable, Identifiable {
    public var id: Self { self }
    case standard
    case dark
    case nostalgia
    case resist
    case national
    case ukrainian
    case pride
}

extension AppIcon {
    init?(name: String) {
        switch name {
        case "AppIcon": self = .standard
        case "AppIconDark": self = .dark
        case "AppIconNostalgia": self = .nostalgia
        case "AppIconResist": self = .resist
        case "AppIconNational": self = .national
        case "AppIconUkrainian": self = .ukrainian
        case "AppIconPride": self = .pride
        default: return nil
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .standard: return "screen.settings.appIcon.icon.default.title"
        case .dark: return "screen.settings.appIcon.icon.dark.title"
        case .nostalgia: return "screen.settings.appIcon.icon.nostalgia.title"
        case .resist: return "screen.settings.appIcon.icon.resist.title"
        case .pride: return "screen.settings.appIcon.icon.pride.title"
        case .national: return "screen.settings.appIcon.icon.belarusFlag.title"
        case .ukrainian: return "screen.settings.appIcon.icon.ukrainianFlag.title"
        }
    }

    var name: String {
        switch self {
        case .standard: return "AppIcon"
        case .dark: return "AppIconDark"
        case .nostalgia: return "AppIconNostalgia"
        case .resist: return "AppIconResist"
        case .national: return "AppIconNational"
        case .ukrainian: return "AppIconUkrainian"
        case .pride: return "AppIconPride"
        }
    }
}
