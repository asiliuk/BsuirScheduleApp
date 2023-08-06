import SwiftUI
import ComposableArchitecture

public struct LoadingErrorUnknownView: View {
    public let store: StoreOf<LoadingErrorUnknown>

    public init(store: StoreOf<LoadingErrorUnknown>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Spacer()
            Text("view.errorState.title").font(.title)
            Button {
                store.send(.reloadButtonTapped)
            } label: {
                Text("view.errorState.button.label")
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
}

struct LoadingErrorUnknownView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingErrorUnknownView(
            store: Store(initialState: (), reducer: EmptyReducer())
        )
    }
}
