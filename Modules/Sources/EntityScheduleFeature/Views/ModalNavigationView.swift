import SwiftUI

struct ModalNavigationStack<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    @ViewBuilder var content: Content

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(
                            action: { dismiss() },
                            label: { Image(systemName: "xmark") }
                        )
                    }
                }
        }
    }
}
