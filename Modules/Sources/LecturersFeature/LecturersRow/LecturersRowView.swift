import SwiftUI
import BsuirUI
import ScheduleFeature
import EntityScheduleFeature
import ComposableArchitecture

struct LecturersRowView: View {
    let store: StoreOf<LecturersRow>

    var body: some View {
        WithPerceptionTracking {
            NavigationLink(state: EntityScheduleFeatureV2.State.lector(.init(lector: store.lector))) {
                LecturerCellView(
                    fullName: store.fullName,
                    imageUrl: store.imageUrl,
                    subtitle: store.subtitle,
                    subtitle2: store.subtitle2
                )
            }
            .accessibilityIdentifier(store.fullName)
            .markedScheduleRowActions(store: store.scope(state: \.mark, action: \.mark))
        }
    }
}
