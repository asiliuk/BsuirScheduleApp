import SwiftUI
import ComposableArchitecture
import BsuirUI

struct TipsAmountsView: View {
    let store: StoreOf<TipsAmounts>

    var body: some View {
        ForEachStore(
            store.scope(
                state: \.amounts,
                action: \.amounts
            ),
            content: TipsAmountRow.init
        )
    }
}

private struct TipsAmountRow: View {
    let store: StoreOf<TipsAmount>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LabeledContent {
                AsyncButton {
                    await viewStore.send(.buyButtonTapped).finish()
                } label: {
                    Text(viewStore.amount)
                }
                .changeEffect(
                    .spray { Text("💸") },
                    value: viewStore.confettiCounter
                )
            } label: {
                Text(viewStore.title)
            }
        }
    }
}
