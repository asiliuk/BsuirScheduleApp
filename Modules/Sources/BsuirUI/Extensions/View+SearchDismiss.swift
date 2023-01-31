import SwiftUI

extension View {
    /// Should be called before `.searchable` modifier
    public func dismissSearch(_ dismiss: Bool) -> some View {
        modifier(SearchDismissingModifier(dismiss: dismiss))
    }
}

struct SearchDismissingModifier: ViewModifier {
    @Environment(\.dismissSearch) private var dismissSearch
    let dismiss: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: dismiss) { dismiss in
                if dismiss { dismissSearch() }
            }
    }
}
