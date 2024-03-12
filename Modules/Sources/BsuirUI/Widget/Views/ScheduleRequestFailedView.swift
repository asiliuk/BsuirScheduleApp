import SwiftUI

struct ScheduleRequestFailedView: View {
    let refresh: Date

    var body: some View {
        VStack(alignment: .leading) {
            Text("widget.failed.title", bundle: .module)
                .font(.headline)
            Text("widget.failed.message\(refresh, style: .relative)", bundle: .module)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct ScheduleRequestFailedSymbolView: View {
    var body: some View {
        Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
    }
}
