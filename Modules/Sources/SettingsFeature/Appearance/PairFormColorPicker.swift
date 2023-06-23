import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

public struct PairFormsColorPicker: ReducerProtocol {
    public struct State: Equatable {
        var hasChanges: Bool = false
        var pairFormColorPickers: IdentifiedArrayOf<PairFormColorPicker.State> = []
        var pairFormIcons: IdentifiedArrayOf<PairFormIcon.State> = []

        public init() {
            @Dependency(\.pairFormColorService) var pairFormColorService
            self.update(service: pairFormColorService)
        }
    }

    public enum Action: Equatable {
        case pairFormColorPickers(id: String, action: PairFormColorPicker.Action)
        case pairFormIcon(id: String, action: PairFormIcon.Action)

        case resetButtonTapped
    }

    @Dependency(\.pairFormColorService) var pairFormColorService

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .resetButtonTapped:
                pairFormColorService.reset()
                state.update(service: pairFormColorService)
                return .none
            case .pairFormColorPickers(let id, .delegate(.colorDidChange)):
                guard let formState = state.pairFormColorPickers[id: id] else { return .none }
                pairFormColorService[formState.form] = formState.color
                state.updateHasChanges(service: pairFormColorService)
                return .none
            case .pairFormColorPickers:
                return .none
            }
        }
        .forEach(\.pairFormColorPickers, action: /Action.pairFormColorPickers) {
            PairFormColorPicker()
        }
        .forEach(\.pairFormIcons, action: /Action.pairFormIcon) {
            PairFormIcon()
        }
    }
}

private extension PairFormsColorPicker.State {
    mutating func update(service: PairFormColorService) {
        updateHasChanges(service: service)
        pairFormColorPickers = IdentifiedArray(
            uncheckedUniqueElements: PairViewForm.allCases.map { form in
                PairFormColorPicker.State(
                    form: form,
                    color: service[form]
                )
            }
        )
        pairFormIcons = IdentifiedArray(
            uncheckedUniqueElements: PairViewForm.allCases
                .map(PairFormIcon.State.init(form:))
        )
    }

    mutating func updateHasChanges(service: PairFormColorService) {
        hasChanges = !service.areDefaultColors
    }
}

public struct PairFormIcon: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: String { form.rawValue }
        var name: LocalizedStringKey { form.name }
        var icon: String { form.symbolName }
        let form: PairViewForm
    }

    public enum Action: Equatable {}

    public var body: some ReducerProtocolOf<Self> {
        EmptyReducer()
    }
}

public struct PairFormColorPicker: ReducerProtocol {
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

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .binding(\.$color):
                return .send(.delegate(.colorDidChange))
            case .delegate, .binding:
                return .none
            }
        }

        BindingReducer()
    }
}
