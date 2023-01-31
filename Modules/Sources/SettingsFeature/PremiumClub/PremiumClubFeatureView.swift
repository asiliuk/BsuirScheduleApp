import SwiftUI
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct PremiumClubFeatureView: View {
    let store: StoreOf<PremiumClubFeature>

    var body: some View {
        NavigationLink {
            PremiumClubContentView(store: store)
        } label: {
            PremiumClubLabel(store: store)
        }
    }
}
