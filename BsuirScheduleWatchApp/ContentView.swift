import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<ContentFeature>

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Current: \(store.counter)")
            Text("High score: \(store.highScore)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack {
                Button("-") { store.send(.decrementButtonTapped) }
                Spacer()
                Button("+") { store.send(.incrementButtonTapped) }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(store: .init(initialState: .init(), reducer: { ContentFeature() }))
}
