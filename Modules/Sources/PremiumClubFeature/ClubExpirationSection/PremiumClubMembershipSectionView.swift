import SwiftUI
import StoreKit
import ComposableArchitecture

struct PremiumClubMembershipSectionView: View {
    let store: StoreOf<PremiumClubMembershipSection>
    @State var manageSubscriptionShown = false
    var body: some View {
        GroupBox {
            SwitchStore(store) { state in
                switch state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity)
                case .noSubscription:
                    VStack(alignment: .leading, spacing: 16) {
                        Text("screen.premiumClub.section.membership.message")
                        LegalInfoView()
                    }
                case .subscribed:
                    CaseLet(
                        /PremiumClubMembershipSection.State.subscribed,
                         action: PremiumClubMembershipSection.Action.subscribed,
                         then: PremiumClubMembershipSubscribedView.init
                    )
                }
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .padding(.vertical, 4)
        } label: {
            Label("screen.premiumClub.section.membership.title", systemImage: "checkmark.seal.fill")
                .settingsRowAccent(.premiumGradient)
        }
        .task { await store.send(.task).finish() }
    }
}

private struct PremiumClubMembershipSubscribedView: View {
    let store: StoreOf<PremiumClubMembershipSubscribed>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                if viewStore.willAutoRenew {
                    Text("screen.premiumClub.section.membership.renew\(viewStore.formattedExpiration)")
                } else {
                    Text("screen.premiumClub.section.membership.expire\(viewStore.formattedExpiration)")
                }
                Button("screen.premiumClub.section.membership.button.manage") {
                    viewStore.send(.manageButtonTapped)
                }
            }
            .manageSubscriptionsSheet(isPresented: viewStore.$manageSubscriptionPresented._onMainQueue())
        }
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
