import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<ContentFeature>

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! \(store.counter)")
            HStack {
                Button("+") { store.send(.incrementButtonTapped) }
                Spacer()
                Button("-") { store.send(.decrementButtonTapped) }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(store: .init(initialState: .init(), reducer: { ContentFeature() }))
}
