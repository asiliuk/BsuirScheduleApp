import SwiftUI
import ComposableArchitecture

struct ClubExpirationSectionView: View {
    let store: StoreOf<ClubExpirationSection>

    var body: some View {
        GroupBox {
            WithViewStore(store, observe: \.expirationText) { viewStore in
                Text(viewStore.state)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }
        } label: {
            Label("Welcome to the club!", systemImage: "checkmark.seal.fill")
                .settingsRowAccent(.premiumGradient)
        }
    }
}
