import Foundation
import BsuirUI
import SwiftUI
import ComposableArchitecture

public struct PairFormIcons: Reducer {
    public struct State: Equatable {
        var pairFormIcons: IdentifiedArrayOf<PairFormIcon.State>

        public init() {
            pairFormIcons = IdentifiedArray(
                uncheckedUniqueElements: PairViewForm.allCases
                    .map(PairFormIcon.State.init(form:))
            )
        }
    }

    public enum Action: Equatable {
        case pairFormIcon(id: String, action: PairFormIcon.Action)
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
        .forEach(\.pairFormIcons, action: /Action.pairFormIcon) {
            PairFormIcon()
        }
    }
}

public struct PairFormIcon: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: String { form.rawValue }
        var name: LocalizedStringKey { form.name }
        var icon: String { form.symbolName }
        let form: PairViewForm
    }

    public enum Action: Equatable {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
