import SwiftUI

struct SettingsLabelStyle: LabelStyle {
    @Environment(\.settingsRowAccent) var settingsRowAccent

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            if let settingsRowAccent {
                configuration.icon
                    .padding(4)
                    .aspectRatio(1, contentMode: .fit)
                    .background { SettingsRowIconBackground(fill: settingsRowAccent) }
                    .foregroundColor(.white)
            } else {
                configuration.icon
            }
        }
    }
}

private struct SettingsRowIconBackground<Fill: ShapeStyle>: View {
    let fill: Fill

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: proxy.size.width * 0.2237)
                .fill(fill)
        }
        .aspectRatio(1, contentMode: .fill)
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
