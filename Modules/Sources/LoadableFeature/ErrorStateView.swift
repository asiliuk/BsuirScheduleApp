import SwiftUI

public struct ErrorStateView: View {

    public let retry: (() -> Void)?
    
    public init(retry: (() -> Void)?) {
        self.retry = retry
    }

    public var body: some View {
        VStack {
            Spacer()
            Text("view.errorState.title").font(.title)
            retry.map {
                Button(action: $0) {
                    Text("view.errorState.button.label")
                }
                .buttonStyle(.bordered)
            }
            Spacer()
        }
    }
}

struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorStateView(retry: nil)
        ErrorStateView(retry: {})
    }
}
