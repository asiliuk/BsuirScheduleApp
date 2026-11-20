import Foundation
import BsuirCore
import SwiftUI
import ReachabilityFeature
import ComposableArchitecture

public struct LoadingErrorSomethingWrongWithBsuirView: View, Animatable {
    public let store: StoreOf<LoadingErrorSomethingWrongWithBsuir>

    public init(store: StoreOf<LoadingErrorSomethingWrongWithBsuir>) {
        self.store = store
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                titleText(errorCode: store.errorCode)
            } icon: {
                AnimatableImage(systemName: "wand.and.rays")
            }
        } description: {
            if let store = store.scope(state: \.reachability, action: \.reachability) {
                ReachabilityView(store: store)
            }

            Text("view.errorState.apiDown.message", bundle: .module)

            NetworkErrorMessageField(
                address: store.address,
                message: store.message
            )
        } actions: {
            Button {
                store.send(.openIssueTapped)
            } label: {
                Label{
                    Text("view.errorState.apiDown.button.issue.label", bundle: .module)
                } icon: {
                    Image(systemName: "plus.diamond.fill")
                }
            }

            Button {
                store.send(.reloadButtonTapped)
            } label: {
                Label{
                    Text("view.errorState.apiDown.button.retry.label", bundle: .module)
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .buttonStyle(.borderedProminent)
    }

    func titleText(errorCode: String) -> Text {
        let errorCodeText = Text(errorCode).fontDesign(.monospaced)
        return Text("view.errorState.apiDown.title.\(errorCodeText)", bundle: .module).font(.title3)
    }
}

struct LoadingErrorSomethingWrongWithBsuirView_Previews: PreviewProvider {
    static var previews: some View {
        let initialState = mutating(LoadingErrorSomethingWrongWithBsuir.State(
            url: URL(string: "https://bsuir.api.by/some/path/for/something"),
            description: "This is test message\nfrom backend...\nmaybe with formatting",
            statusCode: 500
        )) { $0.reachability?.status = .notReachable }

        LoadingErrorSomethingWrongWithBsuirView(
            store: Store(initialState: initialState) {}
        )
    }
}
