import SwiftUI

enum ScrollInitialPositionID {}

/// Put tthis empty view as first element in ScrollView\List to be able to scroll to it.
public struct ScrollTopIdentifyingView: View {
    public init() {}

    public var body: some View {
        EmptyView()
            .id(ObjectIdentifier(ScrollInitialPositionID.self))
    }
}

extension View {
    public func scrollableToTop(
        isOnTop: Binding<Bool>,
        updateOnAppear: Bool = false
    ) -> some View {
        scrollableToTop(
            id: ObjectIdentifier(ScrollInitialPositionID.self),
            isOnTop: isOnTop,
            // For empty view bottom anchor works better
            anchor: .bottom,
            updateOnAppear: updateOnAppear
        )
    }

    public func scrollableToTop<TopId: Hashable>(
        id: TopId,
        isOnTop: Binding<Bool>,
        anchor: UnitPoint? = .top,
        updateOnAppear: Bool = false
    ) -> some View {
        self.modifier(ScrollableToTopModifier(isOnTop: isOnTop, topId: id, anchor: anchor, updateOnAppear: updateOnAppear))
    }
}

struct ScrollableToTopModifier<TopId: Hashable>: ViewModifier {
    @Binding var isOnTop: Bool
    let topId: TopId
    let anchor: UnitPoint?
    let updateOnAppear: Bool

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .onAppear {
                    if isOnTop, updateOnAppear {
                        scrollToTop(proxy: proxy)
                    }
                }
                .onChange(of: isOnTop) { needsToScroll in
                    if needsToScroll {
                        withAnimation {
                            scrollToTop(proxy: proxy)
                        }
                    }
                }
                .gesture(DragGesture().onChanged { _ in
                    isOnTop = false
                })
        }
    }

    private func scrollToTop(proxy: ScrollViewProxy) {
        proxy.scrollTo(topId, anchor: anchor)
    }
}
