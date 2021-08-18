import SwiftUI

struct ContentStateWithSearchView<Model: Identifiable, ItemView: View, BackgroundView: View>: View {
    let content: LoadableContent<[Model]>
    @Binding var searchQuery: String
    let searchPlaceholder: String // TODO: Localize
    @ViewBuilder var itemView: (Model) -> ItemView
    @ViewBuilder var backgroundView: ([Model]) -> BackgroundView

    var body: some View {
        ContentStateView(content: content) { value in
            List {
                ForEach(value) { item in
                    self.itemView(item)
                }
            }
            .dismissingKeyboardOnSwipe()
            .listStyle(.insetGrouped)
            .searchable(text: $searchQuery, prompt: Text(searchPlaceholder))
            .refreshable { await content.refresh() }
        }
        .background(content.state.some.map(backgroundView))
        .onAppear(perform: content.load)
    }
}
