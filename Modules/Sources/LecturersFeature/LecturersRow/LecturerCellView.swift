import SwiftUI
import BsuirUI

struct LecturerCellView: View {
    let fullName: String
    let imageUrl: URL?
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        if sizeCategory.isAccessibilityCategory {
            VStack(alignment: .leading) {
                Avatar(url: imageUrl)
                Text(fullName)
            }
        } else {
            HStack {
                Avatar(url: imageUrl)
                Text(fullName)
            }
        }
    }
}
