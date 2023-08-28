import SwiftUI
import StoreKit
import BsuirUI
import ConfettiSwiftUI
import ComposableArchitecture

public struct PremiumClubFeatureView: View {
    struct ViewState: Equatable {
        var confettiCounter: Int
        var redeemCodePresent: Bool
        var hasPremium: Bool
        var sections: [PremiumClubFeature.Section]

        init(_ state: PremiumClubFeature.State) {
            self.confettiCounter = state.confettiCounter
            self.redeemCodePresent = state.redeemCodePresent
            self.sections = state.sections
            self.hasPremium = state.hasPremium
        }
    }

    let store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ScrollView {
                PremiumClubSections(sections: viewStore.sections, store: store)
            }
            .labelStyle(PremiumGroupTitleLabelStyle())
            .safeAreaInset(edge: .bottom) {
                if !viewStore.hasPremium {
                    SubscriptionFooterView(
                        store: store.scope(
                            state: \.subsctiptionFooter,
                            action: { .subsctiptionFooter($0) }
                        )
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.regularMaterial)
                }
            }
            .premiumClubConfettiCannon(
                counter: viewStore.binding(
                    get: \.confettiCounter,
                    send: { .setConfettiCounter($0) }
                )
            )
            .offerCodeRedemption(
                isPresented: viewStore.binding(
                    get: \.redeemCodePresent,
                    send: { .setRedeemCodePresent($0) }
                )
                ._onMainQueue()
            )
        }
        .navigationTitle("screen.premiumClub.navigation.title")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        store.send(.restoreButtonTapped)
                    } label: {
                        Label("screen.premiumClub.button.restore", systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button {
                        store.send(.redeemCodeButtonTapped)
                    } label: {
                        Label("screen.premiumClub.button.redeemCode", systemImage: "character.textbox")
                    }
                } label: {
                    Label("screen.premiumClub.button.options", systemImage: "ellipsis.circle")
                }
            }
        }
        .task { await store.send(.task).finish() }
    }
}
private struct PremiumClubSections: View {
    let sections: [PremiumClubFeature.Section]
    let store: StoreOf<PremiumClubFeature>

    var body: some View {
        ForEach(sections) { section in
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
        .padding()
    }
}

private extension View {
    func premiumClubConfettiCannon(counter: Binding<Int>) -> some View {
        ZStack(alignment: .top) {
            self
            ConfettiCannon(
                counter: counter,
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
                store: Store(initialState: .init(isModal: true)) {
                    PremiumClubFeature()
                }
            )
        }
    }
}
