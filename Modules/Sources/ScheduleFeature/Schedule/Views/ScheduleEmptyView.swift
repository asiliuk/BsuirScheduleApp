import Foundation
import SwiftUI
import LoadableFeature

struct ScheduleEmptyView: View {
    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: imageNames.randomElement()!,
            description: subtitle
        )
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
