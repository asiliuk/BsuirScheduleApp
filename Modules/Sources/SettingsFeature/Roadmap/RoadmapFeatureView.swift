import SwiftUI
import Roadmap
import ComposableArchitecture

struct RoadmapFeatureView: View {
    let store: StoreOf<RoadmapFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let configuration = RoadmapConfiguration(
                roadmapJSONURL: viewStore.jsonURL,
                voter: FeatureVoterTallyAPI(namespace: viewStore.namespace),
                namespace: viewStore.namespace,
                style: .bsuir
            )

            RoadmapView(configuration: configuration)
        }
    }
}

private extension RoadmapStyle {
    static let bsuir = RoadmapStyle(
        upvoteIcon: Image(systemName: "arrow.up"),
        unvoteIcon: Image(systemName: "arrow.down"),
        titleFont: .title3,
        numberFont: .callout,
        statusFont: .footnote,
        statusTintColor: { _ in .secondary },
        cornerRadius: 16,
        cellColor: Color(uiColor: .secondarySystemBackground),
        selectedColor: .white,
        tint: .purple
    )
}
