import SwiftUI
import ComposableArchitecture
import FakeAdsFeature

struct FakeAdsSectionView: View {
    var store: StoreOf<FakeAdsSection>

    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No more annoing FakeAd™ banners in the app")
                    Button("Why not real ads?") {
                        ViewStore(store.stateless)
                            .send(.whyNotRealAdsTapped)
                    }
                }
                Spacer()
                ZStack {
                    let store = Store(
                        initialState: FakeAdsFeature.State(config: .placeholder),
                        reducer: FakeAdsFeature()
                    )

                    FakeAdsView(store: store)
                        .frame(width: 280, height: 60)
                        .rotationEffect(.degrees(30))

                    FakeAdsView(store: store)
                        .frame(width: 280, height: 60)
                        .rotationEffect(.degrees(-15))
                        .offset(y: -15)

                    FakeAdsView(store: store)
                        .frame(width: 280, height: 60)
                        .rotationEffect(.degrees(-45))

                    Text("✋")
                        .font(.system(size: 100))
                        .unredacted()
                }
                .scaleEffect(x: 0.4, y: 0.4)
                .frame(width: 80, height: 80, alignment: .center)
                .redacted(reason: .placeholder)
            }
        } label: {
            Label("No Fake Ads", systemImage: "hand.raised.square.fill")
                .settingsRowAccent(.purple)
        }
        .alert(
            store: store.scope(
                state: \.$alert,
                action: FakeAdsSection.Action.alert
            )
        )
    }
}
