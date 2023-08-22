import SwiftUI
import ComposableArchitecture

public struct EntityScheduleView: View {
    let state: EntityScheduleFeature.State

    public init(state: EntityScheduleFeature.State) {
        self.state = state
    }

    public var body: some View {
        switch state {
        case .group:
            CaseLet(
                /EntityScheduleFeature.State.group,
                 action: EntityScheduleFeature.Action.group,
                 then: GroupScheduleView.init
            )

        case .lector:
            CaseLet(
                /EntityScheduleFeature.State.lector,
                 action: EntityScheduleFeature.Action.lector,
                 then: LectorScheduleView.init
            )
        }
    }
}
