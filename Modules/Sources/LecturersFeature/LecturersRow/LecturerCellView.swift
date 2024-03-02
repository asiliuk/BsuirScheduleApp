import SwiftUI
import BsuirUI

struct LecturerCellView: View {
    let fullName: String
    let imageUrl: URL?
    let subtitle: String?
    let subtitle2: String?
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        if sizeCategory.isAccessibilityCategory {
            VStack(alignment: .leading) {
                Avatar(url: imageUrl)
                details
            }
        } else {
            HStack {
                Avatar(url: imageUrl)
                details
            }
        }
    }

    @ViewBuilder
    var details: some View {
        VStack(alignment: .leading) {
            Text(fullName)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let subtitle2, !subtitle2.isEmpty {
                Text(subtitle2)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
