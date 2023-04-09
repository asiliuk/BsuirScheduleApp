import SwiftUI

struct NeedsConfigurationView: View {
    var body: some View {
        Text("widget.needsConfiguration.selectSchedule", bundle: .module)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
