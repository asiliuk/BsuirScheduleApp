import SwiftUI
import StoreKit
import ComposableArchitecture

struct PremiumClubMembershipSectionView: View {
    let store: StoreOf<PremiumClubMembershipSection>
    @State var manageSubscriptionShown = false
    
    var body: some View {
        WithPerceptionTracking {
            GroupBox {
                MembershipSubscriptionView(
                    store: store.scope(
                        state: \.subscription,
                        action: \.subscription
                    )
                )
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                .padding(.vertical, 4)
            } label: {
                Label("screen.premiumClub.section.membership.title", systemImage: "checkmark.seal.fill")
                    .settingsRowAccent(.premiumGradient)
            }
            .task { await store.send(.task).finish() }
        }
    }
}

private struct MembershipSubscriptionView: View {
    let store: StoreOf<PremiumClubMembershipSection.MembershipSubscription>

    var body: some View {
        WithPerceptionTracking {
            switch store.case {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
            case .noSubscription:
                VStack(alignment: .leading, spacing: 16) {
                    Text("screen.premiumClub.section.membership.message")
                    LegalInfoView()
                }
            case .subscribed(let store):
                PremiumClubMembershipSubscribedView(store: store)
            }
        }
    }
}

private struct PremiumClubMembershipSubscribedView: View {
    @Perception.Bindable var store: StoreOf<PremiumClubMembershipSubscribed>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 8) {
                if store.willAutoRenew {
                    Text("screen.premiumClub.section.membership.renew\(store.formattedExpiration)")
                } else {
                    Text("screen.premiumClub.section.membership.expire\(store.formattedExpiration)")
                }
                Button("screen.premiumClub.section.membership.button.manage") {
                    store.send(.manageButtonTapped)
                }
            }
            .manageSubscriptionsSheet(isPresented: $store.manageSubscriptionPresented._onMainQueue())
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
