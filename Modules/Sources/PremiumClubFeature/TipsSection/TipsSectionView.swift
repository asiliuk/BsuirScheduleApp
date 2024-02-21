import SwiftUI
import BsuirUI
import ComposableArchitecture
import Pow

struct TipsSectionView: View {
    let store: StoreOf<TipsSection>

    var body: some View {
        WithPerceptionTracking {
            GroupBox {
                VStack(alignment: .leading) {
                    LoadingTipsAmountsView(
                        store: store.scope(
                            state: \.tipsAmounts,
                            action: \.tipsAmounts
                        )
                    )
                    
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
        }
    }
}

