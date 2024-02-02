import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

@Reducer
public struct PairFormsColorPicker {
    @ObservableState
    public struct State: Equatable {
        var hasChanges: Bool = false
        var pairFormColorPickers: IdentifiedArrayOf<PairFormColorPicker.State> = []
    }

    public enum Action: Equatable {
        case onAppear
        case pairFormColorPickers(IdentifiedActionOf<PairFormColorPicker>)
        case resetButtonTapped
    }

    @Dependency(\.pairFormDisplayService) var pairFormDisplayService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                update(state: &state, service: pairFormDisplayService)
                return .none
            case .resetButtonTapped:
                pairFormDisplayService.resetColors()
                update(state: &state, service: pairFormDisplayService)
                return .none
            case .pairFormColorPickers(.element(let id, .delegate(.colorDidChange))):
                guard let formState = state.pairFormColorPickers[id: id] else { return .none }
                pairFormDisplayService.setColor(formState.color, for: formState.form)
                updateHasChanges(state: &state, service: pairFormDisplayService)
                return .none
            case .pairFormColorPickers:
                return .none
            }
        }
        .forEach(\.pairFormColorPickers, action: \.pairFormColorPickers) {
            PairFormColorPicker()
        }

    }

    private func update(state: inout State, service: PairFormDisplayService) {
        updateHasChanges(state: &state, service: service)
        state.pairFormColorPickers = IdentifiedArray(
            uncheckedUniqueElements: PairViewForm.allCases.map { form in
                PairFormColorPicker.State(
                    form: form,
                    color: service.color(for: form)
                )
            }
        )
    }

    private func updateHasChanges(state: inout State, service: PairFormDisplayService) {
        state.hasChanges = !service.areDefaultColors
    }
}

@Reducer
public struct PairFormColorPicker {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: String { form.rawValue }
        var name: LocalizedStringKey { form.name }
        let form: PairViewForm
        var color: PairFormColor
    }

    public enum Action: Equatable, BindableAction {
        public enum DelegateAction: Equatable {
            case colorDidChange
        }

        case binding(BindingAction<State>)
        case delegate(DelegateAction)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.color) { _, _ in
                Reduce { _, _ in
                    .send(.delegate(.colorDidChange))
                }
            }
    }
}
