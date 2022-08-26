import SwiftUI

struct ContentStateWithSearchView<Model: Identifiable, ItemView: View>: View {
    let content: LoadableContent<[Model]>
    @Binding var searchQuery: String
    let searchPlaceholder: LocalizedStringKey
    @ViewBuilder var itemView: (Model) -> ItemView

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
        .onAppear(perform: content.load)
    }
}
