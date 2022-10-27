import SwiftUI

public struct LoadingStateView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 8) {
            Spacer()
            ProgressView()
            Text("view.loadingState.title")
            Spacer()
        }
    }
}

struct LoadingStateView_Preview: PreviewProvider {
    static var previews: some View {
        LoadingStateView()
    }
}
