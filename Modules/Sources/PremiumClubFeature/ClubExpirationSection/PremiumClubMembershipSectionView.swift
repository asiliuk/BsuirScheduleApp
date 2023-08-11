import SwiftUI
import ComposableArchitecture

struct PremiumClubMembershipSectionView: View {
    let store: StoreOf<PremiumClubMembershipSection>

    var body: some View {
        GroupBox {
            WithViewStore(store, observe: { $0 }) { viewStore in
                switch viewStore.state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity)
                case .noSubscription:
                    Text("screen.premiumClub.section.membership.message")
                case let .subscribed(expiration, willAutoRenew):
                    VStack(alignment: .leading, spacing: 8) {
                        let formattedExpiration = expiration?.formatted(date: .long, time: .omitted) ?? "-/-"
                        if willAutoRenew {
                            Text("screen.premiumClub.section.membership.renew\(formattedExpiration)")
                        } else {
                            Text("screen.premiumClub.section.membership.expire\(formattedExpiration)")
                        }
                        Button("screen.premiumClub.section.membership.button.manage") { viewStore.send(.manageButtonTapped) }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        } label: {
            Label("screen.premiumClub.section.membership.title", systemImage: "checkmark.seal.fill")
                .settingsRowAccent(.premiumGradient)
        }
        .task { await store.send(.task).finish() }
    }
}
