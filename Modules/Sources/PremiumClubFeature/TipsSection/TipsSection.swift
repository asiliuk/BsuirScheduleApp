import Foundation
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI
import Favorites
import StoreKit

@Reducer
public struct TipsSection {
    public struct State: Equatable {
        // TODO: Try to use @LoadableState here
        var failedToFetchProducts: Bool = false
        var isLoadingProducts: Bool = false
        var tipsAmounts: TipsAmounts.State = .init()
        var freeLove: FreeLove.State = .init()
    }

    public enum Action: Equatable {
        case task
        case reloadTips
        case tipsAmounts(TipsAmounts.Action)
        case freeLove(FreeLove.Action)

        case _failedToGetProducts
        case _receivedProducts([Product])
    }

    @Dependency(\.productsService) var productsService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return loadTipsProducts(state: &state)

            case .reloadTips:
                return loadTipsProducts(state: &state)

            case let ._receivedProducts(products):
                state.isLoadingProducts = false
                state.failedToFetchProducts = false
                state.tipsAmounts = .init(products: products)
                return .none

            case ._failedToGetProducts:
                state.isLoadingProducts = false
                state.failedToFetchProducts = true
                return .none

            case .freeLove, .tipsAmounts:
                return .none
            }
        }

        Scope(state: \.tipsAmounts, action: \.tipsAmounts) {
            TipsAmounts()
        }

        Scope(state: \.freeLove, action: \.freeLove) {
            FreeLove()
        }
    }

    private func loadTipsProducts(state: inout State) -> Effect<Action> {
        state.isLoadingProducts = true
        state.failedToFetchProducts = false
        return .run { send in
            let products = await productsService.tips
            await send(._receivedProducts(products))
        } catch: { _, send in
            await send(._failedToGetProducts)
        }
    }
}
