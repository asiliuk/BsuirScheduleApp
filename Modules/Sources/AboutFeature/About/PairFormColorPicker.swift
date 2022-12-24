import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PairFormsColorPicker: ReducerProtocol {
    public struct State: Equatable {
        var hasChanges: Bool = false
        var pairFormColorPickers: IdentifiedArrayOf<PairFormColorPicker.State> = []
    }

    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case onAppear
            case resetButtonTapped
        }

        public enum ReducerAction: Equatable {
            case pairFormColorPickers(id: String, action: PairFormColorPicker.Action)
        }

        public typealias DelegateAction = Never

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.pairFormColorService) var pairFormColorService

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                updateColors(state: &state)
                return .none
            case .view(.resetButtonTapped):
                pairFormColorService.reset()
                updateColors(state: &state)
                return .none
            case .reducer(.pairFormColorPickers(let id, .delegate(.colorDidChange))):
                guard let formState = state.pairFormColorPickers[id: id] else { return .none }
                pairFormColorService[formState.form] = formState.color
                updateChanges(state: &state)
                return .none
            case .reducer:
                return .none
            }
        }
        .forEach(\.pairFormColorPickers, reducerAction: /Action.ReducerAction.pairFormColorPickers) {
            PairFormColorPicker()
        }
    }

    private func updateColors(state: inout State) {
        updateChanges(state: &state)
        state.pairFormColorPickers = IdentifiedArray(
            uncheckedUniqueElements: PairViewForm.allCases.map { form in
                PairFormColorPicker.State(
                    form: form,
                    color: pairFormColorService[form]
                )
            }
        )
    }

    private func updateChanges(state: inout State) {
        state.hasChanges = !pairFormColorService.areDefaultColors
    }
}

public struct PairFormColorPicker: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: String { form.rawValue }
        var name: LocalizedStringKey { form.name }
        let form: PairViewForm
        @BindableState var color: PairFormColor
    }

    public enum Action: Equatable, FeatureAction, BindableAction {
        public typealias ViewAction = Never
        public typealias ReducerAction = Never

        public enum DelegateAction: Equatable {
            case colorDidChange
        }

        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .binding(\.$color):
                return .task { .delegate(.colorDidChange) }
            case .delegate, .binding:
                return .none
            }
        }

        BindingReducer()
    }
}
