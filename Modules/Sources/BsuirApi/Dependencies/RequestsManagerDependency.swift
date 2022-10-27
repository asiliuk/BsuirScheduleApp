import Foundation
import Dependencies

extension DependencyValues {
    public var requestsManager: RequestsManager {
        get { self[RequestsManagerKey.self] }
        set { self[RequestsManagerKey.self] = newValue }
    }
}

private enum RequestsManagerKey: DependencyKey {
    static let liveValue = RequestsManager.iisBsuir()
}
