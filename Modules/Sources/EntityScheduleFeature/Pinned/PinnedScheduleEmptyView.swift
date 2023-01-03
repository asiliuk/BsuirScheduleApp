import SwiftUI

public struct PinnedScheduleEmptyView: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "pin.slash")
                .font(.system(size: 50))

            VStack(spacing: 12) {
                Text("screen.pinned.empty.title")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("screen.pinned.empty.message")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
