import SwiftUI

struct AnimatableImage: View {
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
        _Image(systemName: systemName, variableValue: variableValue)
            .onAppear {
                withAnimation(.default.speed(0.3).repeatForever()) {
                    variableValue = 1
                }
            }
    }
}
