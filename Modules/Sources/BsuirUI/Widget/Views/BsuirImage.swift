import SwiftUI

public extension Image {
    static let bsuirLogo = Image(uiImage: UIImage.bsuirLogo ?? UIImage())
}

private extension UIImage {
    static let bsuirLogo = UIImage(named: "bsuir.logo.fill", in: .module, with: nil)?
        .withRenderingMode(.alwaysTemplate)
}
