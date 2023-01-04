import Foundation
import SwiftUI

public enum AppIcon: Hashable {
    public enum Plain: String, CaseIterable, Hashable, Identifiable {
        public var id: Self { self }
        case standard = "AppIconStandart"
        case dark = "AppIconDark"
        case nostalgia = "AppIconNostalgia"
        case bsuirDonalds = "AppIconBsuirDonalds"
    }

    public enum Symbol: String, CaseIterable, Hashable, Identifiable {
        public var id: Self { self }
        case resist = "AppIconResist"
        case national = "AppIconNational"
        case ukrainian = "AppIconUkrainian"
        case pride = "AppIconPride"
    }

    public enum Metal: String, CaseIterable, Hashable, Identifiable {
        public var id: Self { self }
        case silver = "AppIconSilver"
        case copper = "AppIconCopper"
    }

    case plain(Plain)
    case symbol(Symbol)
    case metal(Metal)
}

extension AppIcon {
    init?(name: String) {
        if let plain = Plain(rawValue: name) {
            self = .plain(plain)
        } else if let symbol = Symbol(rawValue: name) {
            self = .symbol(symbol)
        } else if let metal = Metal(rawValue: name) {
            self = .metal(metal)
        } else {
            return nil
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .plain(.standard): return "screen.settings.appIcon.icon.default.title"
        case .plain(.dark): return "screen.settings.appIcon.icon.dark.title"
        case .plain(.nostalgia): return "screen.settings.appIcon.icon.nostalgia.title"
        case .plain(.bsuirDonalds): return "screen.settings.appIcon.icon.bsuirDonalds.title"
        case .symbol(.resist): return "screen.settings.appIcon.icon.resist.title"
        case .symbol(.pride): return "screen.settings.appIcon.icon.pride.title"
        case .symbol(.national): return "screen.settings.appIcon.icon.belarusFlag.title"
        case .symbol(.ukrainian): return "screen.settings.appIcon.icon.ukrainianFlag.title"
        case .metal(.silver): return "screen.settings.appIcon.icon.silver.title"
        case .metal(.copper): return "screen.settings.appIcon.icon.copper.title"
        }
    }

    /// Name used to create UIImage for the app icon
    var imageName: String {
        let previewSuffix = "-Preview"
        switch self {
        case let .plain(icon): return icon.rawValue + previewSuffix
        case let .symbol(icon): return icon.rawValue + previewSuffix
        case let .metal(icon): return icon.rawValue + previewSuffix
        }
    }

    /// Name used to set alternative app icon
    ///
    /// Should be `nil` for default app icon
    var iconName: String? {
        switch self {
        case .plain(.standard): return nil
        case let .plain(icon): return icon.rawValue
        case let .symbol(icon): return icon.rawValue
        case let .metal(icon): return icon.rawValue
        }
    }
}
