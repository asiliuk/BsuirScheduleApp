import UIKit
import Dependencies

extension DependencyValues {
    public var application: ApplicationClient {
        get { self[ApplicationClientKey.self] }
        set { self[ApplicationClientKey.self] = newValue }
    }
}

private enum ApplicationClientKey: DependencyKey {
    static let liveValue = ApplicationClient(application: .shared)
}
