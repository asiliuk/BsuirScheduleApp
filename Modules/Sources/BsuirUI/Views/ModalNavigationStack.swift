import SwiftUI

public struct ModalNavigationStack<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(
                            action: { dismiss() },
                            label: { Image(systemName: "xmark.circle.fill") }
                        )
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                    }
                }
        }
    }
}

struct ModalNavigationStack_Previews: PreviewProvider {
    static var previews: some View {
        ModalNavigationStack {
            Color.gray
                .navigationTitle("Hello World")
                .navigationBarTitleDisplayMode(.inline)

        }
    }
}
