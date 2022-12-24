import SwiftUI

extension View {
    public func task(
        id: some Hashable,
        throttleFor nanoseconds: UInt64,
        _ action: @MainActor @Sendable @escaping() async -> Void
    ) -> some View {
        task(id: id, throttleAction(for: nanoseconds, action))
    }

    public func task(
        throttleFor nanoseconds: UInt64,
        _ action: @MainActor @Sendable @escaping() async -> Void
    ) -> some View {
        task(throttleAction(for: nanoseconds, action))
    }

    private func throttleAction(
        for nanoseconds: UInt64,
        _ action: @MainActor @Sendable @escaping() async -> Void
    ) -> @MainActor @Sendable () async -> Void {
        {
            do {
                try await Task.sleep(nanoseconds: nanoseconds)
                await action()
            } catch {}
        }
    }
}
