import SwiftUI

struct NetworkErrorMessageField: View {
    let address: String
    let message: String

    var body: some View {
        VStack {
            let field = Text("\(addressText)\n\(messageText)")
            #if os(iOS)
                .textSelection(.enabled)
            #endif

            field
                .lineLimit(...10)
                .monospaced()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 6))
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

#Preview("Long message") {
    NetworkErrorMessageField(
        address: "https://my-address.com",
        message: "Network request failed with most strange error ever existed"
    )
}

#Preview("Small message") {
    NetworkErrorMessageField(
        address: "https://my-address.com",
        message: "Tiny error message"
    )
}
