import Foundation
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

public struct GroupsSearch: ReducerProtocol {
    public struct State: Equatable {
        @BindingState var tokens: [StrudentGroupSearchToken] = []
        @BindingState var suggestedTokens: [StrudentGroupSearchToken] = []
        @BindingState var query: String = ""
        fileprivate(set) var dismiss: Bool = false
    }

    public enum Action: Equatable, BindableAction, FeatureAction {
        public enum ViewAction: Equatable {
            case filter
        }

        public typealias ReducerAction = Never

        public enum DelegateAction: Equatable {
            case didUpdateImportantState
        }

        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$query):
                if state.query.isEmpty {
                    state.dismiss = false
                }
                return .none

            case .view(.filter), .binding(\.$tokens):
                return .send(.delegate(.didUpdateImportantState))

            case .binding, .delegate:
                return .none
            }
        }
    }
}

// MARK: - Update

extension GroupsSearch.State {
    mutating func updateSuggestedTokens(for groups: [StudentGroup]) {
        suggestedTokens = {
            switch tokens.last {
            case nil:
                return groups
                    .map(\.faculty)
                    .uniqueSorted(by: <)
                    .map(StrudentGroupSearchToken.faculty)
            case let .faculty(value):
                return groups
                    .filter { $0.faculty == value }
                    .map(\.speciality)
                    .uniqueSorted(by: <)
                    .map(StrudentGroupSearchToken.speciality)
            case let .speciality(value):
                return groups
                    .filter { $0.speciality == value }
                    .map(\.course)
                    .uniqueSorted(by: { ($0 ?? 0) < ($1 ?? 0) })
                    .map(StrudentGroupSearchToken.course)
            case .course:
                return []
            }
        }()
    }
}

// MARK: - Matching

extension GroupsSearch.State {
    func matches(group: StudentGroup) -> Bool {
        guard tokens.matches(group: group) else { return false }
        guard !query.isEmpty else { return true }
        return group.name.localizedCaseInsensitiveContains(query)
    }
}

private extension Array where Element == StrudentGroupSearchToken {
    func matches(group: StudentGroup) -> Bool {
        allSatisfy {
            switch $0 {
            case .faculty(group.faculty),
                 .speciality(group.speciality),
                 .course(group.course):
                return true
            case .faculty, .speciality, .course:
                return false
            }
        }
    }
}

// MARK: - Reset

extension GroupsSearch.State {
    @discardableResult
    mutating func reset() -> Bool {
        guard !query.isEmpty else { return false }
        dismiss = true
        return true
    }
}
