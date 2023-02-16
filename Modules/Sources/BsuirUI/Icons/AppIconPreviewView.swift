import SwiftUI

public struct AppIconPreviewView: View {
    let imageName: String
    @ScaledMetric var size: CGFloat

    public init(imageName: String, size: CGFloat = 34) {
        self.imageName = imageName
        self._size = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    public var body: some View {
        Image(uiImage: iconImage)
            .resizable()
            .frame(width: size, height: size)
    }
    
    private var iconImage: UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { context in
            let path = UIBezierPath(roundedRect: context.format.bounds, cornerRadius: 0.2237 * size )
            path.addClip()

            UIImage(named: imageName)?.draw(in: context.format.bounds)

            UIColor.gray.withAlphaComponent(0.4).setStroke()
            path.stroke()
        }
    }
}
