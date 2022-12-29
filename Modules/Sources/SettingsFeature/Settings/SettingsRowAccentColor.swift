import SwiftUI

private enum SettingsRowAccentColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

extension EnvironmentValues {
    var settingsRowAccentColor: Color? {
        get { self[SettingsRowAccentColorKey.self] }
        set { self[SettingsRowAccentColorKey.self] = newValue }
    }
}

extension View {
    func settingsRowAccentColor(_ color: Color) -> some View {
        environment(\.settingsRowAccentColor, color)
    }
}
