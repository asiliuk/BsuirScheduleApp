import SwiftUI
import BsuirUI
import ComposableArchitecture

public struct PremiumClubLabel: View {
    let store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: \.hasPremium) { viewStore in
            HStack(spacing: 12) {
                SettingsRowIcon(fill: .premiumGradient) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                }

                VStack(alignment: .leading) {
                    let statusText = Text(" \(Image(systemName: "checkmark.seal.fill"))")
                        .foregroundColor(viewStore.state ? .indigo : .clear)

                    Text("Premium Club\(statusText)")
                        .font(.headline)

                    Group {
                        if viewStore.state {
                            Text("You're part of the club now")
                        } else {
                            Text("Become a member of the club")
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            .task { await viewStore.send(.task).finish() }
        }
    }
}

struct PremiumClubLabel_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PremiumClubLabel(
                store: .init(
                    initialState: .init(),
                    reducer: PremiumClubFeature()
                )
            )

            PremiumClubLabel(
                store: .init(
                    initialState: .init(hasPremium: true),
                    reducer: PremiumClubFeature()
                )
            )
        }
    }
}
