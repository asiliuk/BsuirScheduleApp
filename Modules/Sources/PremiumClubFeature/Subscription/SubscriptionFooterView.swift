import SwiftUI
import ComposableArchitecture

struct SubscriptionFooterView: View {
    let store: StoreOf<SubscriptionFooter>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            case .failed:
                Text("Something went wrong...")
            case let .available(product, subscription):
                VStack {
                    // TODO: Check `subscription.isEligibleForIntroOffer`
                    // Maybe move this logic to its own reducer
                    if let introductoryOffer = subscription.introductoryOffer {
                        Text("Start with \(introductoryOffer.makeName())")
                            .font(.subheadline)
                    }

                    Button {
                        viewStore.send(.buttonTapped)
                    } label: {
                        let offer = "\(product.displayPrice) / \(subscription.subscriptionPeriod.makeName())"
                        Text("Join Club for \(offer)")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .task { await ViewStore(store.stateless).send(.task).finish() }
    }
}

import StoreKit

extension Product.SubscriptionOffer {
    func makeName() -> String {
        let period = period.makeName()
        let price = price == 0 ? "free" : displayPrice
        return "\(period) \(price) trial"
    }
}

extension Product.SubscriptionPeriod {
    func makeName() -> String {
        let unitName: String = {
            switch unit {
            case .day: return "Day"
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            @unknown default: return "--"
            }
        }()
        guard value > 1 else { return unitName }
        return "\(value) \(unitName)"
    }
}
