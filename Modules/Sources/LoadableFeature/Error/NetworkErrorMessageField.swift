import SwiftUI

struct NetworkErrorMessageField: View {
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

        if #available(iOS 16.1, *) {
            field.lineLimit(...10)
                .monospaced()
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

struct NetworkErrorMessageField_Previews: PreviewProvider {
    static var previews: some View {
        NetworkErrorMessageField(
            address: "https://my-address.com",
            message: "Network request failed with most strange error ever existed"
        )

        NetworkErrorMessageField(
            address: "https://my-address.com",
            message: "Tiny error message"
        )
    }
}
