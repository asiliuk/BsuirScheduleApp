import Foundation
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI
import Favorites
import StoreKit
import LoadableFeature

@Reducer
public struct TipsSection {
    @ObservableState
    public struct State {
        var tipsAmounts: LoadingState<TipsAmounts.State> = .initial
        var freeLove: FreeLove.State = .init()
    }

    public enum Action {
        case tipsAmounts(LoadingActionOf<TipsAmounts>)
        case freeLove(FreeLove.Action)
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .load(state: \.tipsAmounts, action: \.tipsAmounts) { _, _ in
                let products = await productsService.tips
                return TipsAmounts.State(products: products)
            } loaded: {
                TipsAmounts()
            }

        Scope(state: \.freeLove, action: \.freeLove) {
            FreeLove()
        }
    }
}
