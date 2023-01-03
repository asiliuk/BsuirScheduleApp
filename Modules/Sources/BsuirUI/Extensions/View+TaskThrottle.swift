import SwiftUI

extension View {
    public func task(
        id: some Hashable,
        throttleFor duration: Duration,
        _ action: @MainActor @Sendable @escaping() async -> Void
    ) -> some View {
        task(id: id, throttleAction(for: duration, action))
    }

    public func task(
        throttleFor duration: Duration,
        _ action: @MainActor @Sendable @escaping() async -> Void
    ) -> some View {
        task(throttleAction(for: duration, action))
    }

    private func throttleAction(
        for duration: Duration,
        _ action: @MainActor @Sendable @escaping() async -> Void
    ) -> @MainActor @Sendable () async -> Void {
        {
            do {
                try await Task.sleep(for: duration)
                await action()
            } catch {}
        }
    }
}
