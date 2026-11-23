import Foundation
import SwiftUI

public struct ScheduleEmptyView: View {
    public init() {}

    public var body: some View {
        ContentUnavailableView(
            title,
            systemImage: imageNames.randomElement()!,
            description: subtitle
        )
    }
    
    private let title: LocalizedStringResource = .screenScheduleEmptyStateTitle
    private let subtitle = Text(.screenScheduleEmptyStateSubtitle)

    private let imageNames = [
        "sportscourt",
        "film",
        "house",
        "gamecontroller",
        "eyeglasses"
    ]
}
