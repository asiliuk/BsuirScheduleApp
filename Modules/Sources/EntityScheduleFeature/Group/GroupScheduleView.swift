import SwiftUI
import ScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct GroupScheduleView: View {
    let store: StoreOf<GroupScheduleFeature>
    
    public init(store: StoreOf<GroupScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScheduleFeatureView(store: store)
    }
}
