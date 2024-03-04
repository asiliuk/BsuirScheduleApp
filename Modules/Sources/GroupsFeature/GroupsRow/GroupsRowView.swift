import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct GroupsRowView: View {
    let store: StoreOf<GroupsRow>

    var body: some View {
        WithPerceptionTracking {
            NavigationLinkButton {
                store.send(.rowTapped)
            } label: {
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
