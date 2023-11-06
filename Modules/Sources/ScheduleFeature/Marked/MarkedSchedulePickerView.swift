import SwiftUI
import ComposableArchitecture

struct MarkedSchedulePickerView: View {
    enum ViewState: Identifiable, Hashable, CaseIterable {
        var id: Self { self }
        case pinned
        case favorite
        case nothing
    }

    enum ViewAction: Equatable {
        case task
        case setSelection(ViewState)
    }

    let store: StoreOf<MarkedScheduleFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init, send: MarkedScheduleFeature.Action.init) { viewStore in
            Menu {
                Picker(
                    "screen.schedule.mark.title",
                    selection: viewStore.binding(
                        get: { $0 },
                        send: { .setSelection($0) }
                    )
                ) {
                    ForEach(ViewState.allCases) { $0.label }
                }
            } label: {
                viewStore.state.label
                    .symbolVariant(.fill)
            }
            .task { await store.send(.task).finish() }
            .tint(viewStore.tint)
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: MarkedScheduleFeature.Action.alert
                )
            )
        }
    }
}

private extension MarkedSchedulePickerView.ViewState {
    var label: some View {
        switch self {
        case .pinned:
            Label("screen.schedule.mark.pin", systemImage: "pin")
        case .favorite:
            Label("screen.schedule.mark.favorite", systemImage: "star")
        case .nothing:
            Label("screen.schedule.mark.dontSave", systemImage: "square.dashed")
        }
    }

    var tint: Color {
        switch self {
        case .pinned: return .red
        case .favorite: return .yellow
        case .nothing: return .gray
        }
    }
}

private extension MarkedSchedulePickerView.ViewState {
    init(_ state: MarkedScheduleFeature.State) {
        if state.isPinned {
            self = .pinned
        } else if state.isFavorite {
            self = .favorite
        } else {
            self = .nothing
        }
    }
}

private extension MarkedScheduleFeature.Action {
    init(_ action: MarkedSchedulePickerView.ViewAction) {
        switch action {
        case .task:
            self = .task
        case .setSelection(.pinned):
            self = .pinButtonTapped
        case .setSelection(.favorite):
            self = .favoriteButtonTapped
        case .setSelection(.nothing):
            self = .unsaveButtonTapped
        }
    }
}
