import SwiftUI
import BsuirUI
import Kingfisher

private struct Photo: Identifiable {
    var id: URL { url }
    var url: URL
}

extension View {
    func photoPreview(_ url: Binding<URL?>) -> some View {
        self
            .fullScreenCover(
                item: Binding(
                    get: { url.wrappedValue.map(Photo.init(url:)) },
                    set: { url.transaction($1).wrappedValue = $0?.url }
                )
            ) { photo in
                PhotoPreviewView(url: photo.url)
            }
            .transaction { $0.disablesAnimations = true }
    }
}

private struct PhotoPreviewView: View {
    let url: URL

    @Environment(\.dismiss) var dismiss
    @State var showFade: Bool = false
    @State var additionalOffset = CGSize(width: 0, height: 2000)

    @GestureState(resetTransaction: Transaction(animation: .bouncy)) var scale: Double = 1
    @GestureState(resetTransaction: Transaction(animation: .bouncy)) var degree: Angle = .zero
    @GestureState(resetTransaction: Transaction(animation: .bouncy)) var drag: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            // Calculate how far ff centre for background fade animation
            let distance = sqrt(drag.width * drag.width + drag.height * drag.height)
            let dismissProgress = (distance * 1.5) / proxy.size.width

            ZStack(alignment: .center) {

                Color.black
                    .opacity(showFade ? 0.4 : 0)
                    .opacity(interpolate(from: 1, to: 0.4, progress: dismissProgress))

                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(width: min(proxy.size.width, proxy.size.height) * 0.8)
                    // Update for appear\disappear animation
                    .opacity(showFade ? 1 : 0)
                    .offset(additionalOffset)
                    // Update based on gestures state
                    .offset(drag)
                    .rotationEffect(degree)
                    .scaleEffect(CGSize(width: scale, height: scale))
                    // Monitor gestures
                    .simultaneousGesture(
                        MagnificationGesture()
                            .updating($scale) { value, state, transaction in
                                state = value
                            }
                    )
                    .simultaneousGesture(
                        RotationGesture()
                            .updating($degree) { value, state, transaction in
                                state = value
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .updating($drag) { value, state, transaction in
                                state = value.translation
                            }
                            .onEnded { value in
                                // Calculate how far off centre predicted end translation would be
                                let predictedDistance = sqrt(
                                    value.predictedEndTranslation.width * value.predictedEndTranslation.width +
                                    value.predictedEndTranslation.height * value.predictedEndTranslation.height
                                )

                                let dismissProgress = (predictedDistance * 1.5) / proxy.size.width

                                // Dismiss if dragged too far
                                if dismissProgress > 1 {
                                    dismissView(offset: value.predictedEndTranslation)
                                }
                            }
                    )
            }
            // Dismiss on tap with slide down animation
            .onTapGesture {
                dismissView(offset: CGSize(width: 0, height: 1000))
            }
            .background(
                Material.regular
                    .opacity(showFade ? 1 : 0)
                    .opacity(interpolate(from: 1, to: 0.8, progress: dismissProgress))
            )
        }
        .onAppear {
            withAnimation {
                showFade = true
                additionalOffset = .zero
            }
        }
        .edgesIgnoringSafeArea(.all)
        // Remove fullscreen cover background
        .background(FullScreenCoverBackgroundRemovalView())
    }
}

private extension PhotoPreviewView {
    func interpolate(from: Double, to: Double, clip: Bool = true, progress: Double) -> Double {
        let diff = to - from
        let value = from + diff * progress
        let maxValue = max(from, to)
        let minValue = min(from, to)
        return clip ? min(max(value, minValue), maxValue) : value
    }

    func dismissView(offset: CGSize) {
        let update = {
            showFade = false
            additionalOffset = offset
        }

        if #available(iOS 17, *) {
            withAnimation(.spring) { update() } completion: { dismiss() }
        } else {
            withAnimation(.spring) { update() }
            Task {
                try? await Task.sleep(for: .milliseconds(200))
                dismiss()
            }
        }
    }
}

/// Makes fullscreen cover background transparent
private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }

    func makeUIView(context: Context) -> UIView { BackgroundRemovalView() }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

private struct PhotoPreviewViewPreview: View {
    @State var url: URL?

    var body: some View {
        Button("Show") {
            url = URL(string: "https://iis.bsuir.by/api/v1/employees/photo/500023")
        }
        .photoPreview($url)
    }
}

#Preview("Photo Preview") {
    PhotoPreviewViewPreview()
}
