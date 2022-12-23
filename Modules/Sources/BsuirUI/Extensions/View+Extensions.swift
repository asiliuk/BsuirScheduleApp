import SwiftUI

extension View {
    public func task(
        id: some Hashable,
        throttleFor nanoseconds: UInt64,
        _ work: @MainActor @Sendable @escaping() async -> Void
    ) -> some View {
        task(id: id) {
            do {
                try await Task.sleep(nanoseconds: nanoseconds)
                await work()
            } catch {}
        }
    }
}
