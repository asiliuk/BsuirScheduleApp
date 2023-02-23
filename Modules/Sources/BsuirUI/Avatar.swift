import SwiftUI
import Kingfisher

public struct Avatar: View {
    public let url: URL?
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 50

    public init(
        url: URL?,
        baseSize: Double = 50
    ) {
        self.url = url
        self._size = ScaledMetric(wrappedValue: baseSize, relativeTo: .body)
    }

    public var body: some View {
        KFImage(url)
            .loadDiskFileSynchronously()
            .cacheOriginalImage()
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
