import SwiftUI

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

extension View {
    @ViewBuilder
    public func bsuirNavigationSubtitle(_ subtitle: Text?) -> some View {
        if #available(iOS 26, *), let subtitle {
            navigationSubtitle(subtitle)
        } else {
            self
        }
    }
}
