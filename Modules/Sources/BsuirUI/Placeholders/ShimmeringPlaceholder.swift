import SwiftUI

extension View {
    @ViewBuilder public func shimmeringPlaceholder() -> some View {
        ShimmeringPlaceholderView {
            self
        }
    }
}

private struct ShimmeringPlaceholderView<Content: View>: View {
    @State private var isAnimationAtStart = true
    @State private var isAnimationRunning = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .redacted(reason: .placeholder)
            .foregroundStyle(.placeholderGradient(isAtStart: isAnimationAtStart))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimationAtStart.toggle()
                }
            }
    }
}

private extension ShapeStyle where Self == LinearGradient {
    static func placeholderGradient(isAtStart: Bool) -> Self {
        LinearGradient(
            gradient:  Gradient(stops: [
                .init(color: .primary, location: 0),
                .init(color: .secondary, location: 0.3),
                .init(color: .secondary, location: 0.7),
                .init(color: .primary, location: 1),
            ]),
            startPoint: isAtStart ? UnitPoint(x: -1, y: 0.5) : .trailing,
            endPoint: isAtStart ? .leading : UnitPoint(x: 2, y: 0.5)
        )
    }
}

#Preview {
    VStack {
        Text("Hello")
        Text("World!!!")
    }
    .shimmeringPlaceholder()
}
