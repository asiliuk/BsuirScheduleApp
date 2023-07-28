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
                    Text("Join Premium Club to get access to all cool features!")
                case let .subscribed(expiration, willAutoRenew):
                    VStack(alignment: .leading, spacing: 8) {
                        let formattedExpiration = expiration?.formatted(date: .long, time: .omitted) ?? "-/-"
                        Text("Your subscription will \(willAutoRenew ? "renew" : "expire") \(formattedExpiration)")
                        Button("Manage") { viewStore.send(.manageButtonTapped) }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        } label: {
            Label("Membership", systemImage: "checkmark.seal.fill")
                .settingsRowAccent(.premiumGradient)
        }
        .task { await ViewStore(store.stateless).send(.task).finish() }
    }
}
