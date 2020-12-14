import SwiftUI
import KingfisherSwiftUI
import struct Kingfisher.DownsamplingImageProcessor
import typealias Kingfisher.KingfisherOptionsInfo

public struct Avatar: View {
    public let url: URL?
    public init(url: URL?) { self.url = url }
    @ScaledMetric(relativeTo: .footnote) private var size: CGFloat = 50

    public var body: some View {
        KFImage(url, options: options)
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
