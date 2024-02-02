import Foundation
import ComposableArchitecture

@Reducer
public struct RoadmapFeature {
    @ObservableState
    public struct State: Equatable {
        var jsonURL: URL = .roadmapJSONURL
        var namespace: String = "asiliuk-bsuir-schedule"
    }

    public enum Action: Equatable {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
