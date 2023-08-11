import SwiftUI

struct AppIconsSectionView: View {
    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                Text("screen.premiumClub.section.appIcons.message").font(.body)
                Spacer()
                PremiumAppIconGrid()
                    .frame(width: 80)
            }
        } label: {
            Label("screen.premiumClub.section.appIcons.title", systemImage: "app.gift.fill")
                .settingsRowAccent(.orange)
        }
    }
}
