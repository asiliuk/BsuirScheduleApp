import Foundation
import SwiftUI

// TODO: Find a way to make internal
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
        case .standard: return "screen.about.appearance.icon.default.title"
        case .dark: return "screen.about.appearance.icon.dark.title"
        case .nostalgia: return "screen.about.appearance.icon.nostalgia.title"
        case .resist: return "screen.about.appearance.icon.resist.title"
        case .pride: return "screen.about.appearance.icon.pride.title"
        case .national: return "screen.about.appearance.icon.belarusFlag.title"
        case .ukrainian: return "screen.about.appearance.icon.ukrainianFlag.title"
        }
    }

    var name: String? {
        switch self {
        case .standard: return nil
        case .dark: return "AppIconDark"
        case .nostalgia: return "AppIconNostalgia"
        case .resist: return "AppIconResist"
        case .national: return "AppIconNational"
        case .ukrainian: return "AppIconUkrainian"
        case .pride: return "AppIconPride"
        }
    }
}
