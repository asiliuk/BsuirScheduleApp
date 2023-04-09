import SwiftUI
import BsuirCore

struct WidgetDateTitle: View {
    let date: Date
    var isSmall: Bool = false

    var body: some View {
        Text(date.formatted(isSmall ? .widgetSmall : .widgetNormal))
            .lineLimit(1)
            .allowsTightening(true)
            .environment(\.locale, .current)
    }
}
