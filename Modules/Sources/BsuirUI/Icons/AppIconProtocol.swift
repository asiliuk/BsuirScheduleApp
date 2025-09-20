import Foundation
import SwiftUI

public protocol AppIconProtocol: CaseIterable, Identifiable, Hashable where AllCases: RandomAccessCollection {
    /// Title of the app icon to be displayed on UI
    var title: LocalizedStringKey { get }

    /// Name used to set alternative app icon
    ///
    /// Should be `nil` for default app icon
    var iconName: String? { get }

    /// Name used to create UIImage for the app icon
    var previewImageName: String { get }

    /// Flag indicating that the icon is default app icon
    var isDefault: Bool { get }

    /// Flag indicating that the icon is available as part of `Premium Club`
    var isPremium: Bool { get }

    /// Flag indicating that the icon is safe to be always visible
    var isSafe: Bool { get }
}

// MARK: - Helpers

extension AppIconProtocol {
    public var isDefault: Bool { false }
}

extension AppIconProtocol where Self: RawRepresentable, Self.RawValue == String {
    public var iconName: String? {
        guard !isDefault else { return nil }
        return rawValue
    }

    public var previewImageName: String {
        rawValue + "-Preview"
    }
}

extension AppIconProtocol {
    public var id: Self { self }
}
