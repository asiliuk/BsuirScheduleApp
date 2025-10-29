import SwiftUI
import BsuirUI
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture

struct PinnedScheduleFeatureView: View {
    @Perception.Bindable var store: StoreOf<PinnedScheduleFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                EntityScheduleFeatureViewV2(
                    store: store.scope(state: \.entitySchedule, action: \.entitySchedule)
                )
            } destination: { store in
                EntityScheduleFeatureViewV2(store: store)
            }
        }
    }
}
