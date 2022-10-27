import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct LoadableFeature<Value: Equatable>: ReducerProtocol {
    public typealias State = LodableContentState<Value>
    
    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case task
            case reload
            case refresh
        }
        
        public enum ReducerAction: Equatable {
            case loaded(Value)
            case loadingFailed
        }
        
        public typealias DelegateAction = Never
        
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }
    
    private let fetch: @Sendable () -> EffectTask<TaskResult<Value>>
    
    public init(_ fetch: @Sendable @escaping () -> EffectTask<TaskResult<Value>>) {
        self.fetch = fetch
    }
    
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .view(.task), .view(.reload):
            switch state {
            case .initial, .error:
                state = .loading
                return load()
            case .loading, .some:
                return .none
            }
            
        case .view(.refresh):
            switch state {
            case .error, .some:
                return load()
            case .loading, .initial:
                return .none
            }
            
        case let .reducer(.loaded(value)):
            state = .some(value)
            return .none
            
        case .reducer(.loadingFailed):
            state = .error
            return .none
        }
    }
    
    private enum LoadingCancelId {}
    
    private func load() -> EffectTask<Action> {
        return fetch()
            .map { result in
                switch result {
                case let .success(value):
                    return .reducer(.loaded(value))
                case .failure:
                    return .reducer(.loadingFailed)
                }
            }
            .cancellable(id: LoadingCancelId.self, cancelInFlight: true)
    }
}
