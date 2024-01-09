import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

public struct PairFormsColorPicker: Reducer {
    public struct State: Equatable {
        var hasChanges: Bool = false
        var pairFormColorPickers: IdentifiedArrayOf<PairFormColorPicker.State> = []

        public init() {
            @Dependency(\.pairFormDisplayService) var pairFormDisplayService
            self.update(service: pairFormDisplayService)
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case pairFormColorPickers(IdentifiedActionOf<PairFormColorPicker>)
        case resetButtonTapped
    }

    @Dependency(\.pairFormDisplayService) var pairFormDisplayService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .resetButtonTapped:
                pairFormDisplayService.resetColors()
                state.update(service: pairFormDisplayService)
                return .none
            case .pairFormColorPickers(.element(let id, .delegate(.colorDidChange))):
                guard let formState = state.pairFormColorPickers[id: id] else { return .none }
                pairFormDisplayService.setColor(formState.color, for: formState.form)
                state.updateHasChanges(service: pairFormDisplayService)
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

private extension PairFormsColorPicker.State {
    mutating func update(service: PairFormDisplayService) {
        updateHasChanges(service: service)
        pairFormColorPickers = IdentifiedArray(
            uncheckedUniqueElements: PairViewForm.allCases.map { form in
                PairFormColorPicker.State(
                    form: form,
                    color: service.color(for: form)
                )
            }
        )
    }

    mutating func updateHasChanges(service: PairFormDisplayService) {
        hasChanges = !service.areDefaultColors
    }
}

public struct PairFormColorPicker: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: String { form.rawValue }
        var name: LocalizedStringKey { form.name }
        let form: PairViewForm
        @BindingState var color: PairFormColor
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

        Reduce { state, action in
            switch action {
            case .binding(\.$color):
                return .send(.delegate(.colorDidChange))
            case .delegate, .binding:
                return .none
            }
        }
    }
}
