import SwiftUI

public struct PinnedScheduleLockedView: View {

    var onLearnMoreTapped: () -> Void

    public init(onLearnMoreTapped: @escaping () -> Void) {
        self.onLearnMoreTapped = onLearnMoreTapped
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "pin.fill")
                .foregroundStyle(.premiumGradient)
                .font(.system(size: 50))

            VStack(spacing: 12) {
                Text("screen.pinned.premiumLocked.title")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("screen.pinned.premiumLocked.message")
                    .font(.body)
                    .foregroundColor(.secondary)

                Spacer().frame(height: 24)

                Button {
                    onLearnMoreTapped()
                } label: {
                    Text("screen.pinned.premiumLocked.button.title")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

struct PinnedScheduleLockedView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationStack {
                PinnedScheduleLockedView(onLearnMoreTapped: {})
            }
            .tabItem {
                Label("Test", systemImage: "pin")
            }
        }
    }
}
