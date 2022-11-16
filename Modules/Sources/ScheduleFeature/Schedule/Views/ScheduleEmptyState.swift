import Foundation
import SwiftUI
import LoadableFeature

struct ScheduleEmptyState: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: imageNames.randomElement()!)
                .font(.largeTitle)
            
            title.font(.title)
            subtitle.font(.subheadline)
            
            Spacer()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title + Text(", ") + subtitle)
    }
    
    private let title = Text("screen.schedule.emptyState.title")
    private let subtitle = Text("screen.schedule.emptyState.subtitle")

    private let imageNames = [
        "sportscourt",
        "film",
        "house",
        "gamecontroller",
        "eyeglasses"
    ]
}
