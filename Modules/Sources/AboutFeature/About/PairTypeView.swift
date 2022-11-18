import SwiftUI
import BsuirUI

struct PairTypeView: View {
    var name: LocalizedStringKey
    var form: PairViewForm
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    var body: some View {
        HStack {
            Group {
                if differentiateWithoutColor {
                    form.shape
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                }
            }
            // TODO: Use dynamic color here
            .foregroundColor(.red)
            .frame(width: 30, height: 30)

            Text(name)
        }
    }
}
