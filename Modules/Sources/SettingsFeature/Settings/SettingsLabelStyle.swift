import SwiftUI

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

struct SettingsRowIcon<Icon: View, Fill: ShapeStyle>: View {
    let fill: Fill
    @ViewBuilder var icon: Icon

    var body: some View {
        icon
            .padding(4)
            .aspectRatio(1, contentMode: .fit)
            .background {
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.2237)
                        .fill(fill)
                }
                .aspectRatio(1, contentMode: .fill)
            }
            .foregroundColor(.white)
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
