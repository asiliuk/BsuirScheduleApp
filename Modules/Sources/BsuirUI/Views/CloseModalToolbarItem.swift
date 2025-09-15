import SwiftUI

public struct CloseModalToolbarItem: ToolbarContent {
    let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            if #available(iOS 26, *) {
                Button(
                    action: action,
                    label: { Image(systemName: "xmark") }
                )
            } else {
                Button(
                    action: action,
                    label: { Image(systemName: "xmark.circle.fill") }
                )
                .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
        }
    }
}
