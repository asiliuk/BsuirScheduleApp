import SwiftUI
import ScheduleFeature
import BsuirUI
import ComposableArchitecture

public struct LectorScheduleView: View {
    let store: StoreOf<LectorScheduleFeature>

    public init(store: StoreOf<LectorScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScheduleFeatureView(
            store: store.scope(
                state: \.schedule,
                action: \.schedule
            )
        )
    }
}
