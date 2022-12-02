import Foundation
import BsuirCore
import SwiftUI
import ComposableArchitecture

public struct LoadingErrorFailedToDecodeView: View, Animatable {
    public let store: StoreOf<LoadingErrorFailedToDecode>

    public init(store: StoreOf<LoadingErrorFailedToDecode>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 24) {
                Spacer()

                Group {
                    if #available(iOS 16.0, *) {
                        AnimatableImage(systemName: "ellipsis.curlybraces")
                    } else {
                        Image(systemName: "ellipsis.curlybraces")
                    }
                }
                .font(.system(size: 70))

                VStack(spacing: 12) {
                    Text("view.errorState.parsing.title")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("view.errorState.parsing.message")
                        .font(.body)
                        .foregroundColor(.secondary)

                    ParsingErrorMessageField(
                        address: viewStore.address,
                        message: viewStore.message
                    )
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)

                Button {
                    viewStore.send(.openIssueTapped)
                } label: {
                    Image(systemName: "plus.diamond.fill")
                    Text("view.errorState.parsing.button.label")
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
        }
    }
}

private struct ParsingErrorMessageField: View {
    let address: String
    let message: String

    var body: some View {
        let field = Text("\(addressText)\n\(messageText)")
            .padding(8)
            .textSelection(.enabled)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
            }

        if #available(iOS 16.0, *) {
            field.lineLimit(...10)
        } else {
            field
        }
    }

    private var addressText: Text {
        Text("`\(address)`")
            .foregroundColor(.secondary)
            .font(.footnote)
    }

    private var messageText: Text {
        Text("""
        ```
        \(message.replacingOccurrences(of: "\\", with: ""))
        ```
        """)
        .font(.caption)
    }
}

struct LoadingErrorFailedToDecodeView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingErrorFailedToDecodeView(
            store: Store(
                initialState: .init(
                    url: URL(string: "https://bsuir.api.by/some/path/for/something"),
                    description: "This is test message\n from backend...\n maybe with formatting"
                ),
                reducer: EmptyReducer()
            )
        )
    }
}
