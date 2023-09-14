import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorNoScheduleView: View, Animatable {
    public let store: StoreOf<LoadingErrorNoSchedule>

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            AnimatableImage(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 70))

            VStack(spacing: 12) {
                Text("view.errorState.noSchedule.title")
                    .font(.title2)
                    .bold()

                Text("view.errorState.noSchedule.message")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .multilineTextAlignment(.center)

            Button {
                store.send(.reloadButtonTapped)
            } label: {
                Image(systemName: "repeat")
                Text("view.errorState.noSchedule.button.label")
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
}

#Preview {
    LoadingErrorNoScheduleView(store: Store(initialState: ()) {})
}
