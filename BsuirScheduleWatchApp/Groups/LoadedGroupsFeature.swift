import Foundation
import BsuirApi
import ComposableArchitecture

@Reducer
struct LoadedGroupsFeature {
    @ObservableState
    struct State {
        let groups: [StudentGroup]
    }

    enum Action {}
}
