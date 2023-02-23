import SwiftUI
import Kingfisher

public struct FullScreenAvatar: View {
    public let url: URL?
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 300
    
    private let cornerRadius: CGFloat = 15
    
    public init(url: URL?, baseSize: Double = 300) {
        self.url = url
        self._size = ScaledMetric(wrappedValue: baseSize, relativeTo: .body)
    }
    
    public var body: some View {
        KFImage(url)
            .loadDiskFileSynchronously()
            .cacheOriginalImage()
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color(.systemBackground))
                    .opacity(0.3)
            )
    }
}
