import SwiftUI

struct AppIconPreviewView: View {
    let icon: AppIcon
    @ScaledMetric(relativeTo: .body) var size: CGFloat = 34

    var body: some View {
        Image(uiImage: iconImage)
            .resizable()
            .frame(width: size, height: size)
    }
    
    private var iconImage: UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { context in
            let path = UIBezierPath(roundedRect: context.format.bounds, cornerRadius: 0.2237 * size )
            path.addClip()

            UIImage(named: icon.name)?.draw(in: context.format.bounds)

            UIColor.gray.withAlphaComponent(0.4).setStroke()
            path.stroke()
        }
    }
}
