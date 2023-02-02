import SwiftUI
import BsuirUI

struct SettingsLabelStyle: LabelStyle {
    @Environment(\.settingsRowAccent) var settingsRowAccent

    func makeBody(configuration: Configuration) -> some View {
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
    static let defaultValue: AnyShapeStyle? = nil
}

extension EnvironmentValues {
    var settingsRowAccent: AnyShapeStyle? {
        get { self[SettingsRowAccentKey.self] }
        set { self[SettingsRowAccentKey.self] = newValue }
    }
}

extension View {
    func settingsRowAccent(_ fill: some ShapeStyle) -> some View {
        environment(\.settingsRowAccent, AnyShapeStyle(fill))
    }
}
