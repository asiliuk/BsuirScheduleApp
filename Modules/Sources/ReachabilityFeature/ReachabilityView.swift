import SwiftUI
import BsuirApi
import ComposableArchitecture

public struct ReachabilityView: View {
    let store: StoreOf<ReachabilityFeature>

    public init(store: StoreOf<ReachabilityFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            Label {
                Text(store.host)
            } icon: {
                switch store.status {
                case .unknown:
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.yellow)
                case .notReachable:
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.red)
                case .reachable:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .task { await store.send(.task).finish() }
        }
    }
}
