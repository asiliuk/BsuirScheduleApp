import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

#if DEBUG
public struct DebugPremiumClubRowView: View {
    let store: StoreOf<DebugPremiumClubRow>

    public init(store: StoreOf<DebugPremiumClubRow>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: \.isPremium) { viewStore in
            Toggle(
                "_PremiumClub",
                isOn: viewStore.binding(send: DebugPremiumClubRow.Action.setIsPremium)
            )
            .task { await viewStore.send(.task).finish() }
        }

    }
}
#endif
