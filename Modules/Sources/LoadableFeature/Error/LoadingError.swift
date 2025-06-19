import Foundation
import BsuirCore
import BsuirUI
import BsuirApi
import ComposableArchitecture
import URLRouting

@Reducer
public enum LoadingError {
    case unknown(LoadingErrorUnknown)
    case notConnectedToInternet(LoadingErrorNotConnectedToInternet)
    case failedToDecode(LoadingErrorFailedToDecode)
    case noSchedule(LoadingErrorNoSchedule)
    case somethingWrongWithBsuir(LoadingErrorSomethingWrongWithBsuir)
}
