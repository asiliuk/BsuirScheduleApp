import SwiftUI
import BsuirUI
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
                    }
                }
            }
            .padding()
        }
        .labelStyle(PremiumGroupTitleLabelStyle())
        .safeAreaInset(edge: .bottom) {
            SubscriptionFooterView(
                store: store.scope(
                    state: \.subsctiptionFooter,
                    action: { .subsctiptionFooter($0) }
                )
            )
            .padding()
            .background(.thickMaterial)
        }
        .navigationTitle("Premium Club")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Restore") {}
            }
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
                store: .init(
                    initialState: .init(),
                    reducer: PremiumClubFeature()
                )
            )
        }
    }
}
