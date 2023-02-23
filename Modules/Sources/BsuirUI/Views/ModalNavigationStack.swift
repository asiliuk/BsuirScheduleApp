import SwiftUI

public struct ModalNavigationStack<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    let showCloseButton: Bool
    var content: Content

    public init(
        showCloseButton: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.showCloseButton = showCloseButton
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
                            .opacity(showCloseButton ? 1 : 0)
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
