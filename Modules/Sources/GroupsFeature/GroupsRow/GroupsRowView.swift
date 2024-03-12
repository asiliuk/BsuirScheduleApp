import SwiftUI
import BsuirUI
import ScheduleFeature
import EntityScheduleFeature
import ComposableArchitecture

struct GroupsRowView: View {
    let store: StoreOf<GroupsRow>

    var body: some View {
        WithPerceptionTracking {
            NavigationLink(state: EntityScheduleFeatureV2.State.group(.init(groupName: store.groupName))) {
                VStack(alignment: .leading) {
                    Text(store.title)
                        .monospacedDigit()
                    if let subtitle = store.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .accessibilityIdentifier(store.title)
            .markedScheduleRowActions(
                store: store.scope(state: \.mark, action: \.mark),
                deleteOnUnFavorite: !store.backedByRealGroup
            )
        }
    }
}
