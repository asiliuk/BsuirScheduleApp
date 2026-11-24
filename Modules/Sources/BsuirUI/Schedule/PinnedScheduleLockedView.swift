import SwiftUI

public struct PinnedScheduleLockedView: View {

    var onLearnMoreTapped: () -> Void

    public init(onLearnMoreTapped: @escaping () -> Void) {
        self.onLearnMoreTapped = onLearnMoreTapped
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text(.screenPinnedPremiumLockedTitle)
            } icon: {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.premiumGradient)
            }
        } description: {
            Text(.screenPinnedPremiumLockedMessage)
        } actions: {
            Button(.screenPinnedPremiumLockedButtonTitle, action: onLearnMoreTapped)
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
    }
}

#Preview {
    TabView {
        NavigationStack {
            PinnedScheduleLockedView(onLearnMoreTapped: {})
        }
        .tabItem {
            Label("Test", systemImage: "pin")
        }
    }
}
