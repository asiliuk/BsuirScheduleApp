import SwiftUI
import SwiftUIIntrospect

public struct ScrollableToTopList<Content: View>: View {
    let content: Content
    @Binding var isOnTop: Bool
    @StateObject private var scrollModel = ScrollModel()
    private struct InitialPositionID: Hashable {}

    public init(isOnTop: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._isOnTop = isOnTop
    }

    public var body: some View {
        ScrollViewReader { proxy in
            List {
                EmptyView()
                    .id(InitialPositionID())

                content
                    // TODO: use new iOS 17 API for scroll position here
                    .introspect(
                        .scrollView,
                        on: .iOS(.v16, .v17),
                        scope: .ancestor,
                        customize: scrollModel.bind(to:)
                    )
            }
            .onChange(of: isOnTop) { needsToScroll in
                guard needsToScroll, !scrollModel.isDragging else { return }
                withAnimation { proxy.scrollTo(InitialPositionID(), anchor: .bottom) }
            }
            .onChange(of: scrollModel.isDragging) { newValue in
                if newValue { isOnTop = false }
            }
        }
    }
}

// MARK: - ScrollModel

// TODO: Find a way to sync `isOnTop` with actual `contentOffset` so it would be more correct
private final class ScrollModel: ObservableObject {
    private var scrollView: UIScrollView?
    @Published var isDragging: Bool = false

    func bind(to scrollView: UIScrollView) {
        guard scrollView != self.scrollView else { return }
        self.scrollView = scrollView
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(didScroll))
    }

    @objc private func didScroll(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            isDragging = true
        case .ended, .failed, .cancelled:
            isDragging = false
        case .possible:
            break
        @unknown default:
            break
        }
    }
}
