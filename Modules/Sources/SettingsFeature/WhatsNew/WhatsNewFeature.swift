import Foundation
import WhatsNewKit
import ComposableArchitecture

@Reducer
public struct WhatsNewFeature {
    @ObservableState
    public struct State {
        var whatsNew: WhatsNew
    }
}
