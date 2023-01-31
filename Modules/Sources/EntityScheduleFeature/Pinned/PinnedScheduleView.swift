import SwiftUI
import ComposableArchitecture

public struct PinnedScheduleView: View {
    public let store: StoreOf<PinnedScheduleFeature>

    public init(store: StoreOf<PinnedScheduleFeature>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /PinnedScheduleFeature.State.group, action: PinnedScheduleFeature.Action.group) { store in
                GroupScheduleView(store: store)
            }

            CaseLet(state: /PinnedScheduleFeature.State.lector, action: PinnedScheduleFeature.Action.lector) { store in
                LectorScheduleView(store: store)
            }
        }
    }
}
