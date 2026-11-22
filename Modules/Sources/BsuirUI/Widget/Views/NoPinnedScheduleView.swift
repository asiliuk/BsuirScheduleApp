import SwiftUI

struct NoPinnedScheduleView: View {
    var body: some View {
        VStack {
            NoPinSymbol()
            Text(.widgetNoPinnedTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoPinSymbol: View {
    var body: some View {
        Text(verbatim: "📌")
            .overlay(alignment: .topLeading) { Text(verbatim: "❌").font(.system(size: 5)) }
    }
}

struct NoPinnedScheduleView_Preview: PreviewProvider {
    static var previews: some View {
        NoPinnedScheduleView()
    }
}
