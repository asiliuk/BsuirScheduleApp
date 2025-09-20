import Foundation
import SwiftUI
import BsuirCore
import CasePaths

@dynamicMemberLookup
@CasePathable
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

    public enum Neon: String, CaseIterable {
        case blue = "AppIconNeonBlue"
        case orange = "AppIconNeonOrange"
        case pink = "AppIconNeonPink"
        case red = "AppIconNeonRed"
    }

    public enum Glitch: String, CaseIterable {
        case blue = "AppIconGlitchBlue"
        case gray = "AppIconGlitchGray"
        case pink = "AppIconGlitchPink"
        case orange = "AppIconGlitchOrange"
    }

    case plain(Plain)
    case symbol(Symbol)
    case metal(Metal)
    case neon(Neon)
    case glitch(Glitch)
}

extension AppIcon {
    public init?(name: String) {
        let icon = Plain(rawValue: name).map(Self.plain)
            .or(Symbol(rawValue: name).map(Self.symbol))
            .or(Metal(rawValue: name).map(Self.metal))
            .or(Neon(rawValue: name).map(Self.neon))
            .or(Glitch(rawValue: name).map(Self.glitch))

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
        case .neon(let neon): return neon
        case .glitch(let glitch): return glitch
        }
    }
}

// MARK: - CaseIterable

extension AppIcon: CaseIterable {
    public static var allCases: [AppIcon] {
        return [AppIcon]()
            + Plain.allCases.map(Self.plain)
            + Symbol.allCases.map(Self.symbol)
            + Metal.allCases.map(Self.metal)
            + Neon.allCases.map(Self.neon)
            + Glitch.allCases.map(Self.glitch)
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

    public var isSafe: Bool {
        switch self {
        case .standard, .dark, .nostalgia, .bsuirDonalds, .premium:
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

    public var isSafe: Bool {
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

    public var isSafe: Bool {
        switch self {
        case .silver, .copper:
            return true
        }
    }
}

// MARK: - Neon + AppIconProtocol

extension AppIcon.Neon: AppIconProtocol {
    public var title: LocalizedStringKey {
        switch self {
        case .blue: return "screen.settings.appIcon.icon.neon.blue.title"
        case .orange: return "screen.settings.appIcon.icon.neon.orange.title"
        case .pink: return "screen.settings.appIcon.icon.neon.pink.title"
        case .red: return "screen.settings.appIcon.icon.neon.red.title"
        }
    }

    public var isPremium: Bool {
        switch self {
        case .blue, .orange, .pink, .red:
            return true
        }
    }

    public var isSafe: Bool {
        switch self {
        case .blue, .orange, .pink, .red:
            return true
        }
    }
}

// MARK: - Glitch + AppIconProtocol

extension AppIcon.Glitch: AppIconProtocol {
    public var title: LocalizedStringKey {
        switch self {
        case .blue: return "screen.settings.appIcon.icon.glitch.blue.title"
        case .gray: return "screen.settings.appIcon.icon.glitch.gray.title"
        case .pink: return "screen.settings.appIcon.icon.glitch.pink.title"
        case .orange: return "screen.settings.appIcon.icon.glitch.orange.title"
        }
    }

    public var isPremium: Bool {
        switch self {
        case .blue, .gray, .pink, .orange:
            return true
        }
    }

    public var isSafe: Bool {
        switch self {
        case .blue, .gray, .pink, .orange:
            return true
        }
    }
}
