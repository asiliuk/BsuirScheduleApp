import SwiftUI

struct AnimatableImage: View {
    @available(iOS 16.0, *)
    private struct _Image: View, Animatable {
        let systemName: String
        var variableValue: Double

        var animatableData: Double {
            get { variableValue }
            set { variableValue = newValue }
        }

        var body: some View {
            Image(systemName: systemName, variableValue: min(max(variableValue, 0), 1))
        }
    }

    let systemName: String
    @State var variableValue: Double = -0.1

    var body: some View {
        if #available(iOS 16, *) {
            _Image(systemName: systemName, variableValue: variableValue)
                .animation(.default.speed(0.3).repeatForever(), value: variableValue)
                .onAppear { variableValue = 1 }
        } else {
            Image(systemName: systemName)
        }
    }
}
