import SwiftUI
import BsuirUI
import ComposableArchitecture
import Pow

struct SubscriptionFooterView: View {
    let store: StoreOf<SubscriptionFooter>

    var body: some View {
        WithPerceptionTracking {
            switch store.productState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            case .failed:
                Text("screen.premiumClub.subscribe.failed.title")
            case let .available(info):
                VStack(spacing: 8) {
                    if info.isEligibleForIntroOffer, let introductoryOffer = info.subscription.introductoryOffer {
                        Text(introductoryOffer.makeName())
                            .font(.subheadline)
                    }

                    AsyncButton {
                        await store.send(.buttonTapped).finish()
                    } label: {
                        let period = String(localized: info.subscription.subscriptionPeriod.makeName())
                        let offer = info.product.displayPrice
                        Text("screen.premiumClub.subscribe.button.title\(offer)\(period)")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .conditionalEffect(
                        .repeat(
                            .shine.delay(0.5),
                            every: 2.5
                        ),
                        condition: !store.isPurchasing
                    )
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .task { await store.send(.task).finish() }
    }
}

import StoreKit

extension Product.SubscriptionOffer {
    func makeName() -> LocalizedStringResource {
        let period = String(localized: period.makeName())
        let price = price == 0
            ? String(localized: "screen.premiumClub.subscribe.offer.free")
            : displayPrice
        return "screen.premiumClub.subscribe.offer.trial\(period)\(price)"
    }
}

extension Product.SubscriptionPeriod {
    func makeName() -> LocalizedStringResource {
        // Use zero-based localization variant that don't have digit in it when value is 1
        let value = value <= 1 ? 0 : value
        switch unit {
        case .day: return "screen.premiumClub.subscribe.period.day\(value)"
        case .week: return "screen.premiumClub.subscribe.period.week\(value)"
        case .month: return "screen.premiumClub.subscribe.period.month\(value)"
        case .year: return "screen.premiumClub.subscribe.period.year\(value)"
        @unknown default: return "--"
        }
    }
}
