import SwiftUI
import ComposableArchitecture

extension View {
    public func markedScheduleRowActions(
        store: StoreOf<MarkedScheduleActionsFeature>,
        deleteOnUnFavorite: Bool = false
    ) -> some View {
        modifier(MarkedScheduleRowActionsModifier(store: store, deleteOnUnFavorite: deleteOnUnFavorite))
    }

    @ViewBuilder
    public func markedScheduleToolbar(store: StoreOf<MarkedScheduleActionsFeature>?) -> some View {
        if let store {
            modifier(MarkedScheduleToolbarActionsModifier(store: store))
        } else {
            self
        }
    }
}

struct MarkedScheduleRowActionsModifier: ViewModifier {
    @Bindable var store: StoreOf<MarkedScheduleActionsFeature>
    var deleteOnUnFavorite: Bool

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                PinButton(store: store)
                    .tint(.red)
                    .labelStyle(.iconOnly)
            }
            .swipeActions(edge: .trailing) {
                FavoriteButton(store: store, deleteOnUnFavorite: deleteOnUnFavorite)
                    .tint(deleteOnUnFavorite ? .red : .yellow)
                    .labelStyle(.iconOnly)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
    }
}

struct MarkedScheduleToolbarActionsModifier: ViewModifier {
    @Bindable var store: StoreOf<MarkedScheduleActionsFeature>

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    PinButton(store: store)
                }
                ToolbarItem(placement: .secondaryAction) {
                    FavoriteButton(store: store, deleteOnUnFavorite: false)
                }
            }
            .alert($store.scope(\.alert, action: \.alert))
    }
}

private struct PinButton: View {
    let store: StoreOf<MarkedScheduleActionsFeature>

    var body: some View {
        Button {
            store.send(.togglePinnedTapped)
        } label: {
            store.isPinned ? Label.unpin : Label.pin
        }
    }
}

private struct FavoriteButton: View {
    let store: StoreOf<MarkedScheduleActionsFeature>
    var deleteOnUnFavorite: Bool

    var body: some View {
        Button {
            store.send(deleteOnUnFavorite ? .removeButtonTapped : .toggleFavoriteTapped)
        } label: {
            if store.isFavorite {
                deleteOnUnFavorite ? Label.deleteFromFavorites : Label.removeFromFavorites
            } else {
                Label.addToFavorites
            }
        }
    }
}

private extension Label<Text, Image> {
    static var pin: Label {
        Label("row.markedSchedule.actions.pin.title", systemImage: "pin")
    }

    static var unpin: Label {
        Label("row.markedSchedule.actions.unpin.title", systemImage: "pin.slash")
    }

    static var addToFavorites: Label {
        Label("row.markedSchedule.actions.addToFavorites.title", systemImage: "star")
    }

    static var removeFromFavorites: Label {
        Label("row.markedSchedule.actions.removeFromFavorites.title", systemImage: "star.slash")
    }

    static var deleteFromFavorites: Label {
        Label("row.markedSchedule.actions.deleteFromFavorites.title", systemImage: "trash")
    }
}
