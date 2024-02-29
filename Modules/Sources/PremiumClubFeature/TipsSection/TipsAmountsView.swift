import SwiftUI
import ComposableArchitecture
import BsuirUI
import LoadableFeature
import Pow

struct LoadingTipsAmountsView: View {
    let store: LoadingStoreOf<TipsAmounts>

    var body: some View {
        LoadingView(
            store: store, 
            inProgress: {
                VStack {
                    LabeledContent("Small tip") { Button("X.XX", action: {}) }
                    LabeledContent("Medium tip") { Button("X.XX", action: {}) }
                    LabeledContent("Large tip") { Button("X.XX", action: {}) }
                }
                .redacted(reason: .placeholder)
            }, 
            failed: { store, reload in
                LabeledContent("screen.premiumClub.section.tips.failed.message") {
                    Button("screen.premiumClub.section.tips.failed.button.retry", action: reload)
                }
            },
            loaded: { store, _ in
                TipsAmountsView(store: store)
            }
        )
    }
}

private struct TipsAmountsView: View {
    let store: StoreOf<TipsAmounts>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ForEach(
                    store.scope(
                        state: \.amounts,
                        action: \.amounts
                    ),
                    content: TipsAmountRow.init
                )
            }
        }
    }
}

private struct TipsAmountRow: View {
    let store: StoreOf<TipsAmount>

    var body: some View {
        WithPerceptionTracking {
            LabeledContent {
                AsyncButton {
                    await store.send(.buyButtonTapped).finish()
                } label: {
                    Text(store.amount)
                }
                .changeEffect(
                    .spray { Text("💸") },
                    value: store.confettiCounter
                )
            } label: {
                Text(store.title)
            }
        }
    }
}
