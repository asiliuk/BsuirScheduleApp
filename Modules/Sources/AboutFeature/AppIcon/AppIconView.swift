import SwiftUI

struct AppIconView: View {
    let icon: AppIcon
    let defaultIcon: UIImage?
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 34

    var body: some View {
        image
            .map { Image(uiImage: $0).resizable() }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: (8 / 34) * size, style: .continuous))
    }
    
    private var image: UIImage? {
        icon.name.flatMap(UIImage.init(named:)) ?? defaultIcon
    }
}
