import SwiftUI
import ComposableArchitecture

public struct EntityScheduleFeatureViewV2: View {
    let store: StoreOf<EntityScheduleFeatureV2>

    public init(store: StoreOf<EntityScheduleFeatureV2>) {
        self.store = store
    }

    public var body: some View {
        switch store.case {
        case .group(let store):
            GroupScheduleView(store: store)
        case .lector(let store):
            LectorScheduleView(store: store)
        }
    }
}
