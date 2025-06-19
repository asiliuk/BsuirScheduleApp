import SwiftUI
import BsuirUI
import ComposableArchitecture

public struct PremiumClubLabelView: View {
    let store: StoreOf<PremiumClubLabel>

    public init(store: StoreOf<PremiumClubLabel>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 12) {
                SettingsRowIcon(fill: .premiumGradient) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                }

                VStack(alignment: .leading) {
                    let statusText = Text(" \(Image(systemName: "checkmark.seal.fill"))")
                        // Make it clear to keep space in layout and prevent jumping
                        .foregroundColor(store.isPremiumUser ? .indigo : .clear)

                    (Text("screen.premiumClub.navigation.title") + statusText)
                        .font(.headline)

                    ZStack {
                        if store.isPremiumUser {
                            Text("screen.premiumClub.navigation.member.message")
                        } else {
                            Text("screen.premiumClub.navigation.notMember.message")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    PremiumClubLabelView(
        store: Store(initialState: .init()) {
            PremiumClubLabel()
        }
    )
}

#Preview("Premium") {
    @Shared(.isPremiumUser) var isPremiumUser
    $isPremiumUser.withLock { $0 = true }
    return PremiumClubLabelView(
        store: Store(initialState: .init()) {
            PremiumClubLabel()
        }
    )
}
