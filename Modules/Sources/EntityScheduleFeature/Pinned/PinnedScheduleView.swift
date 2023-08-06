import SwiftUI
import ComposableArchitecture

public struct PinnedScheduleView: View {
    public let store: StoreOf<PinnedScheduleFeature>

    public init(store: StoreOf<PinnedScheduleFeature>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .group:
                CaseLet(
                    /PinnedScheduleFeature.State.group,
                     action: PinnedScheduleFeature.Action.group
                ) { store in
                    GroupScheduleView(store: store)
                }

            case .lector:
                CaseLet(
                    /PinnedScheduleFeature.State.lector,
                     action: PinnedScheduleFeature.Action.lector
                ) { store in
                    LectorScheduleView(store: store)
                }
            }
        }
    }
}
