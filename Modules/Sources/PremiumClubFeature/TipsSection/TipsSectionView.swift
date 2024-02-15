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
                        TipsAmountsView(
                            store: store.scope(
                                state: \.tipsAmounts,
                                action: \.tipsAmounts
                            )
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

