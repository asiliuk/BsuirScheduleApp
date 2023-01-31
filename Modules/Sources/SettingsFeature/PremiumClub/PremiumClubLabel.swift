import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct PremiumClubLabel: View {
    let store: StoreOf<PremiumClubFeature>

    var body: some View {
        WithViewStore(store, observe: \.hasPremium) { viewStore in
            HStack(spacing: 12) {
                SettingsRowIcon(fill: .premiumGradient) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                }

                VStack(alignment: .leading) {
                    let statusText = viewStore.state
                        ? Text(" \(Image(systemName: "checkmark.seal.fill"))").foregroundColor(.indigo)
                        : Text("")

                    Text("Premium Club\(statusText)")
                        .font(.headline)

                    Group {
                        if viewStore.state {
                            Text("You're part of the club now")
                        } else {
                            Text("Become a member of the club")
                        }
                    }
                    .onTapGesture { viewStore.send(._togglePremium) }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
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
