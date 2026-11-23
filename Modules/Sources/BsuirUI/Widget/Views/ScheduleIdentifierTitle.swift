import SwiftUI

struct ScheduleIdentifierTitle: View {
    let title: String

    var body: some View {
        combineTexts(
            Text(Image.bsuirLogo),
            Text(title).font(.subheadline),
            separator: " "
        )
        .lineLimit(1)
    }
}
