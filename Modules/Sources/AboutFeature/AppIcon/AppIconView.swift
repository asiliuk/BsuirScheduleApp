import SwiftUI

struct AppIconView: View {
    let icon: AppIcon
    let defaultIcon: UIImage?
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 34

    var body: some View {
        Image(uiImage: iconImage)
            .resizable()
            .frame(width: size, height: size)
    }
    
    private var iconImage: UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { context in
            let path = UIBezierPath(roundedRect: context.format.bounds, cornerRadius: (8 / 34) * size)
            path.addClip()

            image?.draw(in: context.format.bounds)

            UIColor.gray.withAlphaComponent(0.4).setStroke()
            path.stroke()
        }
    }
    
    private var image: UIImage? {
        icon.name.flatMap(UIImage.init(named:)) ?? defaultIcon
    }
}
