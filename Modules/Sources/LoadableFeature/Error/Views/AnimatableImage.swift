import SwiftUI

struct AnimatableImage: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName, variableValue: 0)
            .symbolEffect(.variableColor.reversing)
    }
}
