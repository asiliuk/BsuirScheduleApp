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
    public func bsuirTabbarSidebarAdaptable() -> some View {
        if #available(iOS 18.0, *) {
            tabViewStyle(.sidebarAdaptable)
        } else {
            self
        }
    }
}
