import Foundation
import SwiftUI
import LoadableFeature

struct ScheduleEmptyView: View {
    var body: some View {
        if #available(iOS 17, *) {
            ContentUnavailableView(
                title,
                systemImage: imageNames.randomElement()!,
                description: subtitle
            )
        } else {
            VStack {
                Spacer()

                Image(systemName: imageNames.randomElement()!)
                    .font(.largeTitle)

                Text(title).font(.title)
                subtitle.font(.subheadline)

                Spacer()
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(title) + Text(", ") + subtitle)
        }
    }
    
    private let title: LocalizedStringKey = "screen.schedule.emptyState.title"
    private let subtitle = Text("screen.schedule.emptyState.subtitle")

    private let imageNames = [
        "sportscourt",
        "film",
        "house",
        "gamecontroller",
        "eyeglasses"
    ]
}
