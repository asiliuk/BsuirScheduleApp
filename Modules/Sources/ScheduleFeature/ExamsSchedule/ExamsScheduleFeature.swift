import Foundation
import BsuirCore
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct ExamsScheduleFeature: ReducerProtocol {
    public struct State: Equatable {
        fileprivate var exams: [Pair]
        
        init(exams: [Pair]) {
            self.exams = exams
        }
    }

    public enum Action: Equatable, FeatureAction {
        public typealias ViewAction = Never
        public typealias ReducerAction = Never
        public typealias DelegateAction = Never

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }


    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        // TODO: Support exams once again
        EmptyReducer()
    }
}
