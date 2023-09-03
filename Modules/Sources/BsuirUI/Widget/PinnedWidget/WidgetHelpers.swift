import SwiftUI

extension View {
    func widgetPadding() -> some View {
        if #available(iOS 17.0, *) {
            return self
        } else {
            return padding()
        }
    }

    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) { color }
        } else {
            return background(color)
        }
    }
}
