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
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 24) {
                Spacer()

                Group {
                    if #available(iOS 16.0, *) {
                        AnimatableImage(systemName: "wand.and.rays")
                    } else {
                        Image(systemName: "wand.and.rays")
                    }
                }
                .font(.system(size: 70))

                VStack(spacing: 12) {

                    titleText(errorCode: viewStore.errorCode)

                    IfLetStore(
                        store.scope(state: \.reachability, action: { .reachability($0) })
                    ) { store in
                        ReachabilityView(store: store)
                            .font(.headline)
                    }

                    Text("view.errorState.apiDown.message")
                        .font(.body)
                        .foregroundColor(.secondary)

                    NetworkErrorMessageField(
                        address: viewStore.address,
                        message: viewStore.message
                    )
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)

                let openIssue = Button {
                    viewStore.send(.openIssueTapped)
                } label: {
                    Label("view.errorState.apiDown.button.issue.label", systemImage: "plus.diamond.fill")
                }

                let retry = Button {
                    viewStore.send(.reloadButtonTapped)
                } label: {
                    Label("view.errorState.apiDown.button.retry.label", systemImage: "arrow.clockwise")
                }

                if #available(iOS 16.0, *) {
                    ViewThatFits {
                        HStack { openIssue; retry }
                        VStack { openIssue; retry }
                    }
                } else {
                    HStack { openIssue; retry }
                }

                Spacer()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    func titleText(errorCode: String) -> Text {
        let errorCodeText: Text
        if #available(iOS 16.1, *) {
            errorCodeText = Text(errorCode).fontDesign(.monospaced)
        } else {
            errorCodeText = Text(errorCode)
        }
        return Text("view.errorState.apiDown.title.\(errorCodeText)").font(.title3)
    }
}

struct LoadingErrorSomethingWrongWithBsuirView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingErrorSomethingWrongWithBsuirView(
            store: Store(
                initialState: mutating(.init(
                    url: URL(string: "https://bsuir.api.by/some/path/for/something"),
                    description: "This is test message\nfrom backend...\nmaybe with formatting",
                    statusCode: 500
                )) { $0.reachability?.status = .notReachable },
                reducer: EmptyReducer()
            )
        )
    }
}
