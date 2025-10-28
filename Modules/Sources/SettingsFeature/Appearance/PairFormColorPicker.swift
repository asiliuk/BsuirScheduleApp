import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

@Reducer
public struct PairFormsColorPicker {
    @ObservableState
    public struct State {
        var hasChanges: Bool { pairFormColorPickers.contains { !$0.isDefault } }
        var pairFormColorPickers = IdentifiedArray(
            uncheckedUniqueElements: PairViewForm.allCases.map(PairFormColorPicker.State.init)
        )
    }

    public enum Action {
        case pairFormColorPickers(IdentifiedActionOf<PairFormColorPicker>)
        case resetButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .resetButtonTapped:
                for formState in state.pairFormColorPickers {
                    formState.resetColor()
                }
                return .none
            case .pairFormColorPickers:
                return .none
            }
        }
        .forEach(\.pairFormColorPickers, action: \.pairFormColorPickers) {
            PairFormColorPicker()
        }
    }
}

@Reducer
public struct PairFormColorPicker {
    @ObservableState
    public struct State: Identifiable {
        public var id: String { form.rawValue }
        var name: LocalizedStringKey { form.name }
        let form: PairViewForm
        @Shared var color: PairFormColor
        var isDefault: Bool { color == form.defaultColor }
        func resetColor() { $color.withLock { $0 = form.defaultColor } }

        init(form: PairViewForm) {
            self.form = form
            _color = Shared(.pairFormColor(for: form))
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
}
