import SwiftUI

public struct NavigationLinkButton<Label: View>: View {
    let action: () -> Void
    let label: Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            action()
        } label: {
            NavigationLink(destination: EmptyView()) {
                label
            }
        }
        .accentColor(.primary)
    }
}
