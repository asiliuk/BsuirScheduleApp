import SwiftUI
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils

public struct FakeAdsView: View {
    let image: Image
    let store: StoreOf<FakeAdsFeature>

    public init(
        image: Image,
        store: StoreOf<FakeAdsFeature>
    ) {
        self.image = image
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.bannerTapped)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Material.regular)
                        .shadow(color: .black.opacity(0.2), radius: 5)

                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(image)
                            .clipped()
                            .font(.system(size: 18))

                        VStack(alignment: .leading) {
                            HStack(alignment: .center, spacing: 4) {
                                Text(viewStore.label)
                                    .padding(.horizontal, 2)
                                    .foregroundColor(Color(uiColor: .systemBackground))
                                    .background { RoundedRectangle(cornerRadius: 4).fill(Color.primary) }
                                    .font(.system(size: 12, weight: .black))

                                Text(viewStore.title)
                                    .lineLimit(1)
                            }
                            .font(.system(size: 16, weight: .semibold))

                            Text(viewStore.description)
                                .lineLimit(2)
                                .font(.system(size: 14))
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(4)
                }
            }
            .buttonStyle(BannerButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: 68)
    }
}

private struct BannerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? CGSize(width: 0.95, height: 0.95) : CGSize(width: 1, height: 1))
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct FakeAdsView_Previews: PreviewProvider {
    static var previews: some View {
        let bannerPreview = FakeAdsView(
            image: Image(systemName: "airplane.departure"),
            store: .init(
                initialState: .init(
                    label: TextState("FakeAD"),
                    title: TextState("This is fake ads title"),
                    description: TextState("Here goes ad description that could be multiline if needed")
                ),
                reducer: FakeAdsFeature()
            )
        )

        TabView {
            NavigationStack {
                List {
                        ForEach(0..<10, id: \.self) { _ in
                            Color.clear.frame(height: 100)
                        }

                }
                .safeAreaInset(edge: .bottom) {
                    bannerPreview
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                }
            }
            .tabItem { Label("Schedule", systemImage: "calendar") }

            Color.clear
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .previewDisplayName("In TabView")

        bannerPreview
            .previewDisplayName("FakeAdsBanner")
            .previewLayout(.sizeThatFits)
            .background(Color.primary)
    }
}
