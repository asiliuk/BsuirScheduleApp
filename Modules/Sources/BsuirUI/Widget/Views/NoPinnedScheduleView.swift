import SwiftUI

struct NoPinnedScheduleView: View {
    var body: some View {
        VStack {
            NoPinSymbol()
            Text("widget.noPinned.title", bundle: .module)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoPinSymbol: View {
    var body: some View {
        Text("📌")
            .overlay(alignment: .topLeading) { Text("❌").font(.system(size: 5)) }
    }
}

struct NoPinnedScheduleView_Preview: PreviewProvider {
    static var previews: some View {
        NoPinnedScheduleView()
    }
}
