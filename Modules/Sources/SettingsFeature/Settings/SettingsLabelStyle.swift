import SwiftUI

struct SettingsLabelStyle: LabelStyle {
    @Environment(\.settingsRowAccentColor) var settingsRowAccentColor

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            if let settingsRowAccentColor {
                SettingsRowIconBackground(color: settingsRowAccentColor)
                    .overlay(alignment: .center) {
                        configuration.icon
                            .foregroundColor(.white)
                    }
            } else {
                configuration.icon
            }
        }
    }
}

private struct SettingsRowIconBackground: View {
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: proxy.size.width * 0.2237)
                .fill(color)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
