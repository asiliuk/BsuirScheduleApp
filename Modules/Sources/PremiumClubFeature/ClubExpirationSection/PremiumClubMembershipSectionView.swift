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
                    LegalInfoView()
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

private struct LegalInfoView: View {

    var body: some View {
        let privacyPolicy = link(label: "screen.premiumClub.section.membership.legal.privacy", url: .privacyPolicy)
        let termsAndConditions = link(label: "screen.premiumClub.section.membership.legal.terms", url: .termsAndConditions)

        Text("screen.premiumClub.section.membership.legal\(privacyPolicy)\(termsAndConditions)")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private func link(label: LocalizedStringResource, url: URL) -> AttributedString {
        var attributes = AttributeContainer()
        attributes.link = url
        return AttributedString(String(localized: label), attributes: attributes)
    }
}
