import SwiftUI

extension View {
    @ViewBuilder
    @available(iOS 17, *)
    @available(watchOS, unavailable)
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
    @available(iOS 17, *)
    @available(watchOS, unavailable)
    public func bsuirNavigationSubtitle(_ subtitle: Text?) -> some View {
        if #available(iOS 26, *), let subtitle {
            navigationSubtitle(subtitle)
        } else {
            self
        }
    }
}
