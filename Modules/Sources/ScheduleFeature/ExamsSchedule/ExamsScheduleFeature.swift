import Foundation
import BsuirCore
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils
import Dependencies

public struct ExamsScheduleFeature: ReducerProtocol {
    public struct State: Equatable {
        fileprivate var exams: [Pair]
        fileprivate let startDate: Date?
        fileprivate let endDate: Date?
        
        init(exams: [Pair], startDate: Date?, endDate: Date?) {
            self.exams = exams
            self.startDate = startDate
            self.endDate = endDate
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
