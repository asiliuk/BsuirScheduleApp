import SwiftUI

public struct PlaceholderView<Content: View>: View {
    let speed: Double
    let content: (Int) -> Content

    public init(speed: Double, @ViewBuilder content: @escaping (Int) -> Content) {
        self.speed = speed
        self.content = content
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: speed)) { context in
            let iteration = iteration(date: context.date)
            content(iteration)
                .animation(.default, value: iteration)
                .redacted(reason: .placeholder)
        }
    }

    func iteration(date: Date) -> Int {
        Int(date.timeIntervalSinceReferenceDate / speed)
    }
}
