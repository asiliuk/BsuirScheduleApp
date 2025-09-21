import SwiftUI
import StoreKit
import BsuirUI
import ConfettiSwiftUI
import ComposableArchitecture

public struct PremiumClubFeatureView: View {
    @Perception.Bindable var store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                PremiumClubSections(sections: store.sections, store: store)
            }
            .labelStyle(PremiumGroupTitleLabelStyle())
            .bsuirSafeAreaBar(edge: .bottom) {
                if !store.isPremiumUser {
                    SubscriptionFooterView(
                        store: store.scope(
                            state: \.subsctiptionFooter,
                            action: \.subsctiptionFooter
                        )
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(subscriptionBackground)
                }
            }
            .premiumClubConfettiCannon(counter: $store.confettiCounter)
            .offerCodeRedemption(isPresented: $store.redeemCodePresent._onMainQueue())
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

    private var subscriptionBackground: some ShapeStyle {
        if #available(iOS 26, *) {
            return .clear
        } else {
            return .regularMaterial
        }
    }
}

private extension View {
    @ViewBuilder
    func bsuirSafeAreaBar(edge: VerticalEdge, @ViewBuilder content: @escaping () -> some View) -> some View {
        if #available(iOS 26, *) {
            self.safeAreaBar(edge: edge, content: content)
        } else {
            self.safeAreaInset(edge: edge, content: content)
        }
    }
}

private struct PremiumClubSections: View {
    let sections: [PremiumClubFeature.Section]
    let store: StoreOf<PremiumClubFeature>

    var body: some View {
        ForEach(sections) { section in
            WithPerceptionTracking {
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
                            action: \.tips
                        )
                    )
                case .premiumClubMembership:
                    PremiumClubMembershipSectionView(
                        store: store.scope(
                            state: \.premiumClubMembership,
                            action: \.premiumClubMembership
                        )
                    )
                }
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
