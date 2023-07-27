import SwiftUI
import ComposableArchitecture

struct SubscriptionFooterView: View {
    let store: StoreOf<SubscriptionFooter>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .progressViewStyle(.circular)
            case .failed:
                Text("Something went wrong...")
            case let .available(product, subscription):
                Button {
                    viewStore.send(.buttonTapped)
                } label: {
                        VStack {
                            Text("Join Premium Club!").bold()
                            let offer = "\(product.displayPrice)/\(subscription.subscriptionPeriod.makeName())"
                            if let introductoryOffer = subscription.introductoryOffer {
                                Text("\(introductoryOffer.makeName()) then \(offer)")
                            } else {
                                Text(offer)
                            }
                        }
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            }
        }
        .task { await ViewStore(store.stateless).send(.task).finish() }
    }
}

import StoreKit

extension Product.SubscriptionOffer {
    func makeName() -> String {
        let period = period.makeName()
        let price = price == 0 ? "free" : displayPrice
        return "\(price) \(period) trial"
    }
}

extension Product.SubscriptionPeriod {
    func makeName() -> String {
        let unitName: String = {
            switch unit {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            @unknown default: return "--"
            }
        }()
        guard value > 1 else { return unitName }
        return "\(value)-\(unitName)"
    }
}
