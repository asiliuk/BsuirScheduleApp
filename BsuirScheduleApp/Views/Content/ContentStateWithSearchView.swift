import SwiftUI

struct ContentStateWithSearchView<Model: Identifiable, ItemView: View>: View {

    let content: LoadableContent<[Model]>
    @Binding var searchQuery: String
    let searchPlaceholder: String // TODO: Localize
    let itemView: (Model) -> ItemView

    init(
        content: LoadableContent<[Model]>,
        searchQuery: Binding<String>,
        searchPlaceholder: String,
        @ViewBuilder itemView: @escaping (Model) -> ItemView
    ) {
        self.content = content
        self._searchQuery = searchQuery
        self.searchPlaceholder = searchPlaceholder
        self.itemView = itemView
    }

    var body: some View {
        ContentStateView(content: content) { value in
            List {
                Section(header: SearchBar(text: self.$searchQuery, placeholder: self.searchPlaceholder)) {
                    ForEach(value) { item in
                        self.itemView(item)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .dismissingKeyboardOnSwipe()
        }
        .onAppear(perform: content.load)
    }
}
