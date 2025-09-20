import SwiftUI
import Kingfisher

public struct Avatar: View {
    @ScaledMetric private var size: CGFloat
    public let url: URL?

    public init(url: URL?, baseSize: CGFloat = 50) {
        self.url = url
        _size = ScaledMetric(wrappedValue: baseSize, relativeTo: .body)
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
            Color(.secondarySystemFill)
            Image(systemName: "photo").foregroundColor(.secondary)
        }
    }
}

private struct AvatarShape: Shape {
    func path(in rect: CGRect) -> Path {
        Circle().path(in: rect)
    }
}

#Preview {
    PairCell(
        from: "10:00",
        to: "11:30",
        interval: "10:00 - 11:30",
        subject: "POIT",
        weeks: nil,
        subgroup: nil,
        auditory: "101-2",
        note: "Don't forget your pants",
        form: .unknown,
        progress: .init(constant: 0),
        details: Avatar(url: URL(string: "https://google.com"))
    )
    .environmentObject(PairFormDisplayService.noop)
}
