import SwiftUI

struct NoPairsView: View {
    var body: some View {
        Text(.widgetScheduleEmpty)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
