import SwiftUI

struct AppIconsSectionView: View {
    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                Text("Unlock stunning new icons, I've spent a lot of time designing them, more to come...").font(.body)
                Spacer()
                PremiumAppIconGrid()
                    .frame(width: 80)
            }
        } label: {
            Label("Custom App Icons", systemImage: "app.gift.fill")
                .settingsRowAccent(.orange)
        }
    }
}
