import SwiftUI
import URLImage

public struct Avatar: View {
    public let url: URL?
    public init(url: URL?) { self.url = url }
    @ScaledMetric(relativeTo: .footnote) private var size: CGFloat = 50

    public var body: some View {
        Group {
            if let url = url {
                RemoteAvatar(url: url, targetSize: targetSize)
            } else {
                UserPlaceholder()
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .clipShape(AvatarShape())
        .overlay(AvatarShape().stroke(lineWidth: 1).foregroundColor(Color(.systemBackground).opacity(0.3)))
    }

    private var targetSize: CGSize { CGSize(width: size, height: size) }
}

private struct RemoteAvatar: View {

    let url: URL
    let targetSize: CGSize

    var body: some View {
        URLImage(
            url,
            processors: [Resize(size: targetSize, scale: UIScreen.main.scale)],
            placeholder: { _ in UserPlaceholder() },
            content: {
               $0.image
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .clipped()
            }
        )
    }
}

private struct UserPlaceholder: View {

    var body: some View {
        ZStack {
            AvatarShape().foregroundColor(.gray)
            Image(systemName: "photo").foregroundColor(.black)
        }
    }
}

private struct AvatarShape: Shape {
    func path(in rect: CGRect) -> Path {
        Circle().path(in: rect)
    }
}
