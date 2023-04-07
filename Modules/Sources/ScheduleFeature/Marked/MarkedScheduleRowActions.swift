import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

extension View {
    public func markedScheduleRowActions(store: StoreOf<MarkedScheduleFeature>) -> some View {
        modifier(MarkedScheduleRowActions(store: store))
    }
}

struct MarkedScheduleRowActions: ViewModifier {
    let store: StoreOf<MarkedScheduleFeature>

    func body(content: Content) -> some View {
        WithViewStore(
            store,
            observe: { (isPinned: $0.isPinned, isFavorite: $0.isFavorite) },
            removeDuplicates: ==
        ) { viewStore in
            content
                // This triggers listening for favorites & pinned updates
                // since we have correct initial value it is *ok* to wait some time before triggering this
                // otherwise it is very heavy load when list is scrolled
                .task(throttleFor: .seconds(2)) { await viewStore.send(.task).finish() }
                .swipeActions(edge: .leading) {
                    swipeButton(viewStore.isPinned ? .unpin : .pin, send: viewStore.send).tint(.red)
                }
                .swipeActions(edge: .trailing) {
                    swipeButton(viewStore.isFavorite ? .removeFromFavorites : .addToFavorites, send: viewStore.send).tint(.yellow)
                }
                .alert(
                    store: store.scope(
                        state: \.$alert,
                        action: MarkedScheduleFeature.Action.alert
                    )
                )
        }
    }

    private func swipeButton(
        _ config: SwipeButtonConfig,
        send: @escaping (MarkedScheduleFeature.Action, Animation?
    ) -> ViewStoreTask) -> some View {
        Button {
            _ = send(config.action, Animation.default)
        } label: {
            Label(config.title, systemImage: config.systemImage)
        }
    }
}

private struct SwipeButtonConfig {
    var action: MarkedScheduleFeature.Action
    var title: LocalizedStringKey
    var systemImage: String

    static let pin = SwipeButtonConfig(
        action: .pinButtonTapped,
        title: "row.markedSchedule.actions.pin.title",
        systemImage: "pin"
    )

    static let unpin = SwipeButtonConfig(
        action: .unpinButtonTapped,
        title: "row.markedSchedule.actions.unpin.title",
        systemImage: "pin.slash"
    )

    static let addToFavorites = SwipeButtonConfig(
        action: .favoriteButtonTapped,
        title: "row.markedSchedule.actions.addToFavorites.title",
        systemImage: "star"
    )

    static let removeFromFavorites = SwipeButtonConfig(
        action: .unfavoriteButtonTapped,
        title: "row.markedSchedule.actions.removeFromFavorites.title",
        systemImage: "star.slash"
    )
}
