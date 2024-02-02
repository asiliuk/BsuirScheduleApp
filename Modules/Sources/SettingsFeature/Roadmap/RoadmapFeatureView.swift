import SwiftUI
import Roadmap
import ComposableArchitecture

struct RoadmapFeatureView: View {
    let store: StoreOf<RoadmapFeature>

    var body: some View {
        WithPerceptionTracking {
            let configuration = RoadmapConfiguration(
                roadmapJSONURL: store.jsonURL,
                voter: FeatureVoterTallyAPI(namespace: store.namespace),
                namespace: store.namespace,
                style: .bsuir
            )

            RoadmapView(configuration: configuration)
        }
        .navigationTitle("screen.settings.roadmap.navigation.title")
    }
}

private extension RoadmapStyle {
    static let bsuir = RoadmapStyle(
        upvoteIcon: Image(systemName: "arrow.up"),
        unvoteIcon: Image(systemName: "arrow.down"),
        titleFont: .title3,
        numberFont: .callout,
        statusFont: .footnote,
        statusTintColor: { status in
            switch status {
            case "next_release": .green
            case "planned": .blue
            case "idea": .yellow
            default: .secondary
            }
        },
        cornerRadius: 16,
        cellColor: Color(uiColor: .secondarySystemBackground),
        selectedColor: .white,
        tint: .purple
    )
}
