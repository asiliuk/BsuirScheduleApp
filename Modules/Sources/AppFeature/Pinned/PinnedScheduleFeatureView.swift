import SwiftUI
import BsuirUI
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture

struct PinnedScheduleFeatureView: View {
    let store: StoreOf<PinnedScheduleFeature>

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
            SwitchStore(
                store.scope(
                    state: \.entitySchedule,
                    action: { .entitySchedule($0) }
                ),
                content: EntityScheduleView.init
            )
        } destination: { state in
            EntityScheduleView(state: state)
        }
    }
}
