import SwiftUI

struct ScheduleIdentifierTitle: View {
    let title: String

    var body: some View {
        Text("\(Image.bsuirLogo) \(Text(title).font(.subheadline))")
            .lineLimit(1)
    }
}
