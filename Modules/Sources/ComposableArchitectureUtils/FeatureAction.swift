import ComposableArchitecture

public protocol FeatureAction {
    associatedtype ViewAction
    associatedtype DelegateAction
    associatedtype ReducerAction
    
    static func view(_: ViewAction) -> Self
    static func delegate(_: DelegateAction) -> Self
    static func reducer(_: ReducerAction) -> Self
}
