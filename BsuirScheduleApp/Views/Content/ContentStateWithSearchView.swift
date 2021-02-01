import SwiftUI

struct ContentStateWithSearchView<Model: Identifiable, ItemView: View, BackgroundView: View>: View {

    let content: LoadableContent<[Model]>
    @Binding var searchQuery: String
    let searchPlaceholder: String // TODO: Localize
    let itemView: (Model) -> ItemView
    let backgroundView: ([Model]) -> BackgroundView

    init(
        content: LoadableContent<[Model]>,
        searchQuery: Binding<String>,
        searchPlaceholder: String,
        @ViewBuilder itemView: @escaping (Model) -> ItemView,
        @ViewBuilder backgroundView: @escaping ([Model]) -> BackgroundView
    ) {
        self.content = content
        self._searchQuery = searchQuery
        self.searchPlaceholder = searchPlaceholder
        self.itemView = itemView
        self.backgroundView = backgroundView
    }

    var body: some View {
        ContentStateView(content: content) { value in
            List {
                Section(header: SearchBar(text: self.$searchQuery, placeholder: self.searchPlaceholder)) {
                    EmptyView()
                }

                ForEach(value) { item in
                    self.itemView(item)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .dismissingKeyboardOnSwipe()
            .background(backgroundView(value))
        }
        .onAppear(perform: content.load)
    }
}
