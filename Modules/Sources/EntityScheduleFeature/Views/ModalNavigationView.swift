import SwiftUI

struct ModalNavigationView<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    @ViewBuilder var content: Content

    var body: some View {
        NavigationView {
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            action: { dismiss() },
                            label: { Image(systemName: "xmark") }
                        )
                    }
                }
        }
    }
}
