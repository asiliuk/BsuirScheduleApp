import Foundation
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorNoScheduleView: View, Animatable {
    public let store: StoreOf<LoadingErrorNoSchedule>

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text("view.errorState.noSchedule.title", bundle: .module)
            } icon: {
                AnimatableImage(systemName: "chart.bar.doc.horizontal")
            }
        } description: {
            Text("view.errorState.noSchedule.message", bundle: .module)
        } actions: {
            Button {
                store.send(.reloadButtonTapped)
            } label: {
                Label {
                    Text("view.errorState.noSchedule.button.label", bundle: .module)
                } icon: {
                    Image(systemName: "repeat")
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    LoadingErrorNoScheduleView(store: Store(initialState: .init()) {})
}
