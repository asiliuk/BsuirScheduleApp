import SwiftUI

public struct SettingsRowIcon<Icon: View, Fill: ShapeStyle>: View {
    let fill: Fill
    let icon: Icon

    public init(fill: Fill, @ViewBuilder icon: () -> Icon) {
        self.fill = fill
        self.icon = icon()
    }

    public var body: some View {
        icon
            .padding(4)
            .aspectRatio(1, contentMode: .fit)
            .background {
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.2237)
                        .fill(fill)
                }
                .aspectRatio(1, contentMode: .fill)
            }
            .foregroundColor(.white)
    }
}
