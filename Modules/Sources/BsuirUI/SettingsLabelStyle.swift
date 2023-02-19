import SwiftUI

extension LabelStyle where Self == SettingsLabelStyle {
    public static var settings: SettingsLabelStyle { .init() }
}

public struct SettingsLabelStyle: LabelStyle {
    @Environment(\.settingsRowAccent) var settingsRowAccent

    public func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            if let settingsRowAccent {
                SettingsRowIcon(fill: settingsRowAccent) {
                    configuration.icon
                }
            } else {
                configuration.icon
            }
        }
    }
}

// MARK: - Accent Color

private enum SettingsRowAccentKey: EnvironmentKey {
    public static let defaultValue: AnyShapeStyle? = nil
}

extension EnvironmentValues {
    public var settingsRowAccent: AnyShapeStyle? {
        get { self[SettingsRowAccentKey.self] }
        set { self[SettingsRowAccentKey.self] = newValue }
    }
}

extension View {
    public func settingsRowAccent(_ fill: some ShapeStyle) -> some View {
        environment(\.settingsRowAccent, AnyShapeStyle(fill))
    }
}
