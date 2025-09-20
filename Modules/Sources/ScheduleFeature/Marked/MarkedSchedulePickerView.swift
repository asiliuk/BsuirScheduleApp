import SwiftUI
import ComposableArchitecture

struct MarkedSchedulePickerView: View {
    @Perception.Bindable var store: StoreOf<MarkedSchedulePickerFeature>
    @State var selection: MarkedSchedulePickerFeature.State.Selection = .nothing

    var body: some View {
        WithPerceptionTracking {
            Menu {
                Picker("screen.schedule.mark.title", selection: $selection) {
                    ForEach(MarkedSchedulePickerFeature.State.Selection.allCases) { selection in
                        selection.label
                    }
                }
                .tint(nil)
            } label: {
                store.selection.label
                    .symbolVariant(.fill)
            }
            .task { await store.send(.task).finish() }
            .tint(store.selection.tint)
            .alert($store.scope(state: \.alert, action: \.alert))
            .bind($store.selection, to: $selection)
        }
    }
}

private extension MarkedSchedulePickerFeature.State.Selection {
    @ViewBuilder
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
