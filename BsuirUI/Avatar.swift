import SwiftUI
import Kingfisher
import struct Kingfisher.DownsamplingImageProcessor
import typealias Kingfisher.KingfisherOptionsInfo

public struct Avatar: View {
    public let url: URL?
    public init(url: URL?) { self.url = url }
    private var size: CGFloat = 50

    public var body: some View {
        KFImage(url)
            .setProcessor(DownsamplingImageProcessor(
                size: CGSize(width: size, height: size)
            ))
            .loadDiskFileSynchronously()
            .cacheMemoryOnly()
            .placeholder { UserPlaceholder() }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(AvatarShape())
            .overlay(
                AvatarShape()
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color(.systemBackground))
                    .opacity(0.3)
            )
    }

    private var options: KingfisherOptionsInfo {
        [
            .processor(DownsamplingImageProcessor(
                size: CGSize(width: size, height: size)
            )),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
        ]
    }
}

private struct UserPlaceholder: View {

    var body: some View {
        ZStack {
            Color.gray
            Image(systemName: "photo").foregroundColor(.black)
        }
    }
}

private struct AvatarShape: Shape {
    func path(in rect: CGRect) -> Path {
        Circle().path(in: rect)
    }
}

//private struct RemoteImage<Placeholder: View>: View {
//    @StateObject var binder: KFImage.ImageBinder
//    let cancelOnDisappear: Bool
//    let placeholder: Placeholder
//
//    init(_ url: URL?, cancelOnDisappear: Bool = false, @ViewBuilder placeholder: () -> Placeholder) {
//        self._loader = StateObject(wrappedValue: KFImage.ImageBinder(url))
//        self.cancelOnDisappear = cancelOnDisappear
//        self.placeholder = placeholder()
//    }
//
//    var body: some View {
//        if let image = binder.image {
//            Image(uiImage: image)
//        } else {
//            placeholder
//                .onAppear { binder.start() }
//                .onDisappear { if cancelOnDisappear { binder.cancel() } }
//        }
//    }
//}
//
//private final class RemoteImageLoader: ObservableObject {
//    @Published private(set) var image: UIImage?
//
//    init(_ url: URL?) {
//
//    }
//
//    func loadIfNeeded() {
//
//    }
//
//    func cancel() {
//
//    }
//}
