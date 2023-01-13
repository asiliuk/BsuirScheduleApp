import SwiftUI

extension ShapeStyle where Self == LinearGradient {
    public static var premiumGradient: Self {
        LinearGradient(
            colors: [.pink, .indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
