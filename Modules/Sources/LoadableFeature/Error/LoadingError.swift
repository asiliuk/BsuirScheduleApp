import Foundation
import BsuirCore
import BsuirUI
import BsuirApi
import ComposableArchitecture
import URLRouting

@Reducer
public struct LoadingError {
    @ObservableState
    public enum State: Equatable {
        case unknown
        case notConnectedToInternet
        case failedToDecode(LoadingErrorFailedToDecode.State)
        case noSchedule
        case somethingWrongWithBsuir(LoadingErrorSomethingWrongWithBsuir.State)
    }

    public enum Action: Equatable {
        case reload
        case unknown(LoadingErrorUnknown.Action)
        case notConnectedToInternet(LoadingErrorNotConnectedToInternet.Action)
        case failedToDecode(LoadingErrorFailedToDecode.Action)
        case noSchedule(LoadingErrorNoSchedule.Action)
        case somethingWrongWithBsuir(LoadingErrorSomethingWrongWithBsuir.Action)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .somethingWrongWithBsuir(.reloadButtonTapped),
                 .notConnectedToInternet(.reloadButtonTapped),
                 .noSchedule(.reloadButtonTapped),
                 .unknown(.reloadButtonTapped):
                return .send(.reload)
            case .reload,
                 .failedToDecode(.openIssueTapped),
                 .somethingWrongWithBsuir(.reachability),
                 .somethingWrongWithBsuir(.openIssueTapped):
                return .none
            }
        }
        .ifCaseLet(\.unknown, action: \.unknown) {
            LoadingErrorUnknown()
        }
        .ifCaseLet(\.failedToDecode, action: \.failedToDecode) {
            LoadingErrorFailedToDecode()
        }
        .ifCaseLet(\.somethingWrongWithBsuir, action: \.somethingWrongWithBsuir) {
            LoadingErrorSomethingWrongWithBsuir()
        }
        .ifCaseLet(\.noSchedule, action: \.noSchedule) {
            LoadingErrorNoSchedule()
        }
        .ifCaseLet(\.notConnectedToInternet, action: \.notConnectedToInternet) {
            LoadingErrorNotConnectedToInternet()
        }
    }
}
