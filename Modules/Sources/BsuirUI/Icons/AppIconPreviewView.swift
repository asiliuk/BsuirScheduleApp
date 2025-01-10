import SwiftUI

public struct ScaledAppIconPreviewView: View {
    let imageName: String
    let size: CGFloat

    public init(imageName: String, size: CGFloat = 34) {
        self.imageName = imageName
        self.size = size
    }

    public var body: some View {
        AppIconPreviewView(imageName: imageName, size: size)
    }
}

public struct AppIconPreviewView: View {
    let imageName: String
    let size: CGFloat

    public init(imageName: String, size: CGFloat) {
        self.imageName = imageName
        self.size = size
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

            if let image = UIImage(named: imageName) {
                image.draw(in: context.format.bounds)
            } else {
                #if DEBUG
                let value = abs(imageName.hashValue).quotientAndRemainder(dividingBy: 360).remainder
                UIColor(hue: CGFloat(value) / 360, saturation: 1, brightness: 1, alpha: 1).setFill()
                path.fill()
                #endif
            }

            UIColor.gray.withAlphaComponent(0.4).setStroke()
            path.stroke()
        }
    }
}
