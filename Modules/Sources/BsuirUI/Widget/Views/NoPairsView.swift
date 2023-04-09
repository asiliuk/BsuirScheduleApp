import SwiftUI

struct NoPairsView: View {
    var body: some View {
        Text("widget.schedule.empty", bundle: .module)
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
