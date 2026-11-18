import SwiftUI

extension View {
    @ViewBuilder
    public func bsuirRemovingSidebarToggle() -> some View {
        if #available(iOS 17, *) {
            toolbar(removing: .sidebarToggle)
        } else {
            self
        }
    }
}


extension View {
    @ViewBuilder
    public func bsuirTabbarOnly() -> some View {
        if #available(iOS 18.0, *) {
            tabViewStyle(.tabBarOnly)
        } else {
            self
        }
    }
}
