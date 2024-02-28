import SwiftUI
import ComposableArchitecture

extension View {
    public func markedScheduleRowActions(store: StoreOf<MarkedScheduleRowFeature>) -> some View {
        modifier(MarkedScheduleRowActions(store: store))
    }
}

struct MarkedScheduleRowActions: ViewModifier {
    @Perception.Bindable var store: StoreOf<MarkedScheduleRowFeature>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .swipeActions(edge: .leading) {
                    Button {
                        store.send(.togglePinnedTapped)
                    } label: {
                        store.isPinned ? Label.unpin : Label.pin
                    }
                    .tint(.red)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        store.send(.toggleFavoriteTapped)
                    } label: {
                        store.isFavorite ? Label.removeFromFavorites : Label.addToFavorites
                    }
                    .tint(.yellow)
                }
                .alert($store.scope(state: \.alert, action: \.alert))
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
}
