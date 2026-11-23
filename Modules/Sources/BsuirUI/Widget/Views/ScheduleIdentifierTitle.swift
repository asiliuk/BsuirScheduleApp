import SwiftUI

struct ScheduleIdentifierTitle: View {
    let title: String

    var body: some View {
        Text(verbatim: "\(Image.bsuirLogo) \(Text(title).font(.subheadline))")
            .lineLimit(1)
    }
}
