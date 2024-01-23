import SwiftUI
import BsuirUI
import ComposableArchitecture
import Pow

struct TipsSectionView: View {
    let store: StoreOf<TipsSection>

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                WithViewStore(
                    store,
                    observe: { (failedToFetchProducts: $0.failedToFetchProducts, isLoadingProducts: $0.isLoadingProducts) },
                    removeDuplicates: ==
                ) { viewStore in
                    if viewStore.isLoadingProducts {
                        VStack {
                            LabeledContent("Small tip") { Button("X.XX", action: {}) }
                            LabeledContent("Medium tip") { Button("X.XX", action: {}) }
                            LabeledContent("Large tip") { Button("X.XX", action: {}) }
                        }
                        .redacted(reason: .placeholder)
                    } else if viewStore.failedToFetchProducts {
                        LabeledContent("screen.premiumClub.section.tips.failed.message") {
                            Button("screen.premiumClub.section.tips.failed.button.retry") {
                                viewStore.send(.reloadTips)
                            }
                        }
                    } else {
                        ForEachStore(
                            store.scope(
                                state: \.tipsAmounts,
                                action: \.tipsAmounts
                            ),
                            content: TipsAmountRow.init
                        )
                    }
                }

                FreeLoveView(
                    store: store.scope(
                        state: \.freeLove,
                        action: \.freeLove
                    )
                )
            }
            .buttonStyle(.borderedProminent)
        } label: {
            Label("screen.premiumClub.section.tips.title", systemImage: "heart.square.fill")
                .settingsRowAccent(.pink)
        }
        .task {
            await store.send(.task).finish()
        }
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

private struct FreeLoveView: View {
    let store: StoreOf<FreeLove>
    @State var buttonTappedCount: UInt = 0

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LabeledContent {
                Button {
                    viewStore.send(.loveButtonTapped)
                    buttonTappedCount += 1
                } label: {
                    HStack {
                        AnimatableFreeLoveText(counter: Double(viewStore.counter))
                        if viewStore.counter > 0 {
                            Text("\(Image(systemName: "heart.fill"))")
                        } else {
                            Text("\(Image(systemName: "heart"))")
                        }
                    }
                }
                .changeEffect(
                    .spray(origin: UnitPoint(x: 1, y: 0.5)) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    },
                    value: viewStore.confettiCounter
                )
                .changeEffect(
                    .rise(origin: UnitPoint(x: 1, y: 0.5)) {
                        Text("+\(Image(systemName: "heart.fill"))")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    },
                    value: buttonTappedCount
                )
            } label: {
                Text("screen.premiumClub.section.tips.freeLove.title")
                if viewStore.highScore > 0 {
                    Text("screen.premiumClub.section.tips.freeLove.count\(String(viewStore.highScore))")
                }
            }
        }
    }
}

private struct AnimatableFreeLoveText: View, Animatable {
    var counter: Double

    var animatableData: Double {
        get { counter }
        set { counter = newValue }
    }

    var body: some View {
        if counter > 0 {
            Text("\(Int(counter.rounded(.up)))").monospaced()
        }
    }
}
