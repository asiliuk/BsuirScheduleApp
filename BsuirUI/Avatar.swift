import SwiftUI
import URLImage

public struct Avatar: View {
    public let url: URL?
    public init(url: URL?) { self.url = url }

    public var body: some View {
        Group {
            if let url = url {
                RemoteAvatar(url: url, targetSize: targetSize)
            } else {
                UserPlaceholder()
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .clipShape(Circle())
    }

    private let targetSize = CGSize(width: 50, height: 50)
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
            Circle().foregroundColor(Color.gray)
            Image(systemName: "photo")
        }
    }
}
