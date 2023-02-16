import Foundation
import SwiftUI
import BsuirCore

@dynamicMemberLookup
public enum AppIcon: Hashable {
    public enum Plain: String, CaseIterable {
        case standard = "AppIconStandart"
        case dark = "AppIconDark"
        case nostalgia = "AppIconNostalgia"
        case bsuirDonalds = "AppIconBsuirDonalds"
        case premium = "AppIconPremium"
    }

    public enum Symbol: String, CaseIterable {
        case resist = "AppIconResist"
        case national = "AppIconNational"
        case ukrainian = "AppIconUkrainian"
        case pride = "AppIconPride"
    }

    public enum Metal: String, CaseIterable {
        case silver = "AppIconSilver"
        case copper = "AppIconCopper"
    }

    case plain(Plain)
    case symbol(Symbol)
    case metal(Metal)
}

extension AppIcon {
    public init?(name: String) {
        let icon = Plain(rawValue: name).map(Self.plain)
            .or(Symbol(rawValue: name).map(Self.symbol))
            .or(Metal(rawValue: name).map(Self.metal))

        guard let icon else { return nil }
        self = icon
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<any AppIconProtocol, T>) -> T {
        appIcon[keyPath: keyPath]
    }

    private var appIcon: any AppIconProtocol {
        switch self {
        case .plain(let plain): return plain
        case .symbol(let symbol): return symbol
        case .metal(let metal): return metal
        }
    }
}

// MARK: - CaseIterable

extension AppIcon: CaseIterable {
    public static var allCases: [AppIcon] {
        return []
            + Plain.allCases.map(Self.plain)
            + Symbol.allCases.map(Self.symbol)
            + Metal.allCases.map(Self.metal)
    }
}

// MARK: - Plain + AppIconProtocol

extension AppIcon.Plain: AppIconProtocol {
    public var title: LocalizedStringKey {
        switch self {
        case .standard: return "screen.settings.appIcon.icon.default.title"
        case .dark: return "screen.settings.appIcon.icon.dark.title"
        case .nostalgia: return "screen.settings.appIcon.icon.nostalgia.title"
        case .bsuirDonalds: return "screen.settings.appIcon.icon.bsuirDonalds.title"
        case .premium: return "screen.settings.appIcon.icon.premium.title"
        }
    }

    public var isDefault: Bool {
        return self == .standard
    }

    public var isPremium: Bool {
        switch self {
        case .standard, .dark, .nostalgia:
            return false
        case .bsuirDonalds, .premium:
            return true
        }
    }
}

// MARK: - Symbol + AppIconProtocol

extension AppIcon.Symbol: AppIconProtocol {
    public var title: LocalizedStringKey {
        switch self {
        case .resist: return "screen.settings.appIcon.icon.resist.title"
        case .national: return "screen.settings.appIcon.icon.belarusFlag.title"
        case .ukrainian: return "screen.settings.appIcon.icon.ukrainianFlag.title"
        case .pride: return "screen.settings.appIcon.icon.pride.title"
        }
    }

    public var isPremium: Bool {
        switch self {
        case .resist, .national, .ukrainian, .pride:
            return false
        }
    }
}

// MARK: - Metal + AppIconProtocol

extension AppIcon.Metal: AppIconProtocol {
    public var title: LocalizedStringKey {
        switch self {
        case .silver: return "screen.settings.appIcon.icon.silver.title"
        case .copper: return "screen.settings.appIcon.icon.copper.title"
        }
    }

    public var isPremium: Bool {
        switch self {
        case .silver, .copper:
            return true
        }
    }
}
