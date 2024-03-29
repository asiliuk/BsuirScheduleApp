import SwiftUI
import BsuirUI
import ComposableArchitecture

public struct PremiumClubLabel: View {
    let store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
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
                        .foregroundColor(store.hasPremium ? .indigo : .clear)

                    (Text("screen.premiumClub.navigation.title") + statusText)
                        .font(.headline)

                    ZStack {
                        if store.hasPremium {
                            Text("screen.premiumClub.navigation.member.message")
                        } else {
                            Text("screen.premiumClub.navigation.notMember.message")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .task { await store.send(.task).finish() }
        }
    }
}

struct PremiumClubLabel_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PremiumClubLabel(
                store: Store(initialState: .init(isModal: false)) {
                    PremiumClubFeature()
                }
            )

            PremiumClubLabel(
                store: Store(initialState: .init(isModal: false, hasPremium: true)) {
                    PremiumClubFeature()
                }
            )
        }
    }
}
