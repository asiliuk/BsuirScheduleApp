import SwiftUI

public struct PinnedScheduleEmptyView: View {
    public init() {}

    public var body: some View {
        ContentUnavailableView {
            Label(.screenPinnedEmptyTitle, systemImage: "pin.slash")
        } description: {
            Text(.screenPinnedEmptyMessage)
        }
    }
}
