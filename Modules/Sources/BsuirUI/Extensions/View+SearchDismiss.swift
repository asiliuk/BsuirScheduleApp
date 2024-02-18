import SwiftUI

extension View {
    /// Should be called before `.searchable` modifier
    public func dismissSearch(_ dismiss: Int) -> some View {
        modifier(SearchDismissingModifier(dismiss: dismiss))
    }
}

struct SearchDismissingModifier: ViewModifier {
    @Environment(\.dismissSearch) private var dismissSearch
    let dismiss: Int

    func body(content: Content) -> some View {
        content
            .onChange(of: dismiss) { dismiss in
                if dismiss > 0 { dismissSearch() }
            }
    }
}
