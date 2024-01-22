import SwiftUI
import BsuirUI
import EntityScheduleFeature
import PremiumClubFeature
import ComposableArchitecture

struct PinnedScheduleFeatureView: View {
    let store: StoreOf<PinnedScheduleFeature>

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            SwitchStore(
                store.scope(
                    state: \.entitySchedule,
                    action: \.entitySchedule
                ),
                content: EntityScheduleView.init
            )
        } destination: { state in
            EntityScheduleView(state: state)
        }
    }
}
