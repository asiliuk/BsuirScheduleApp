import SwiftUI
import ComposableArchitecture

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
                                action: TipsSection.Action.tipsAmount
                            ),
                            content: TipsAmountRow.init
                        )
                    }
                }

                FreeLoveView(
                    store: store.scope(
                        state: \.freeLove,
                        action: TipsSection.Action.freeLove
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
                Button {
                    viewStore.send(.buyButtonTapped)
                } label: {
                    Text(viewStore.amount)
                }
            } label: {
                Text(viewStore.title)
            }
        }
    }
}

private struct FreeLoveView: View {
    let store: StoreOf<FreeLove>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LabeledContent {
                Button {
                    viewStore.send(.loveButtonTapped)
                } label: {
                    HStack {
                        AnimatableFreeLoveText(counter: Double(viewStore.counter))
                        Text("\(Image(systemName: "heart.fill"))")
                    }
                }
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
