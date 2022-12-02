import Foundation
import BsuirCore
import SwiftUI

public struct DecodingErrorStateView: View, Animatable {
    public let url: URL?
    public let message: String
    @Environment(\.openURL) var openURL

    public init(url: URL?, message: String) {
        self.url = url
        self.message = message
    }

    public var body: some View {
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

                ParsingErrorMessageField(url: url, message: message)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 24)

            Button {
                openURL(issueUrl)
            } label: {
                Image(systemName: "plus.diamond.fill")
                Text("view.errorState.parsing.button.label")
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }


    private var issueUrl: URL {
        return .githubIssue(
            title: "Failed to parse",
            body: issueBody,
            labels: "bug", "parsing"
        )
    }

    private var issueBody: String {
        return """
        ## While requesting
        \(url?.absoluteString ?? "--")

        ## Received fllowing error
        ```
        \(message)
        ```
        """
    }
}

private struct ParsingErrorMessageField: View {
    let url: URL?
    let message: String

    var body: some View {
        let field = Text("\(urlText)\n\(messageText)")
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

    private var urlText: Text {
        Text("`\(url?.absoluteString ?? "")`")
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

struct DecodingErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        DecodingErrorStateView(
            url: URL(string: "https://bsuir.api.by/some/path/for/something"),
            message: "This is test message\n from backend...\n maybe with formatting"
        )
    }
}
