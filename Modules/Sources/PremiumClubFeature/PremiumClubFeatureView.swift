import SwiftUI
import BsuirUI
import ConfettiSwiftUI
import ComposableArchitecture

public struct PremiumClubFeatureView: View {
    let store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            WithViewStore(store, observe: \.sections) { viewStore in
                ForEach(viewStore.state) { section in
                    switch section {
                    case .pinnedSchedule:
                        PinnedScheduleSectionView()
                    case .widgets:
                        WidgetsSectionView()
                    case .appIcons:
                        AppIconsSectionView()
                    case .tips:
                        TipsSectionView(
                            store: store.scope(
                                state: \.tips,
                                action: { .tips($0) }
                            )
                        )
                    case .premiumClubMembership:
                        PremiumClubMembershipSectionView(
                            store: store.scope(
                                state: \.premiumClubMembership,
                                action: { .premiumClubMembership($0) }
                            )
                        )
                    }
                }
            }
            .padding()
        }
        .overlay(alignment: .top) {
            ConfettiView(store: store)
        }
        .labelStyle(PremiumGroupTitleLabelStyle())
        .safeAreaInset(edge: .bottom) {
            WithViewStore(store, observe: \.hasPremium) { viewStore in
                if !viewStore.state {
                    SubscriptionFooterView(
                        store: store.scope(
                            state: \.subsctiptionFooter,
                            action: { .subsctiptionFooter($0) }
                        )
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.thickMaterial)
                }
            }
        }
        .navigationTitle("Premium Club")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Restore") { store.send(.restoreButtonTapped) }
            }
        }
        .task { await store.send(.task).finish() }
    }
}

private struct ConfettiView: View {
    let store: StoreOf<PremiumClubFeature>

    var body: some View {
        WithViewStore(store, observe: \.confettiCounter) { viewStore in
            Color.clear
                .frame(height: 10)
                .confettiCannon(
                    counter: viewStore.binding(send: { .setConfettiCounter($0) }),
                    num: 40,
                    confettis: [.text("🎉"), .text("🎊"), .text("🎈"), .text("🪅"), .text("🥳"), .text("🍾"), .text("💸")],
                    confettiSize: 20,
                    openingAngle: Angle(degrees: 150),
                    closingAngle: Angle(degrees: 30),
                    radius: 200,
                    repetitions: 2,
                    repetitionInterval: 0.8
                )
        }
    }
}

private struct PremiumGroupTitleLabelStyle: LabelStyle {
    @Environment(\.settingsRowAccent) var settingsRowAccent

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            if let settingsRowAccent {
                configuration.icon
                    .font(.title2.bold())
                    .foregroundStyle(settingsRowAccent)
            }
        }
    }
}

struct PremiumClubFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PremiumClubFeatureView(
                store: Store(initialState: .init()) {
                    PremiumClubFeature()
                }
            )
        }
    }
}
