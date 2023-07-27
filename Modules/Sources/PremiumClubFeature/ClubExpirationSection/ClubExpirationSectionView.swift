import SwiftUI
import ComposableArchitecture

struct ClubExpirationSectionView: View {
    let store: StoreOf<ClubExpirationSection>

    var body: some View {
        GroupBox {
            WithViewStore(store, observe: \.expirationText) { viewStore in
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.state)
                    Button("Manage") { viewStore.send(.manageButtonTapped) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
        } label: {
            Label("Welcome to the club!", systemImage: "checkmark.seal.fill")
                .settingsRowAccent(.premiumGradient)
        }
    }
}
