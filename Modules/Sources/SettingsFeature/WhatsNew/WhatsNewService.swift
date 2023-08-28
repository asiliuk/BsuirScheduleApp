import WhatsNewKit
import Dependencies

public protocol WhatsNewService {
    func whatsNew() -> WhatsNew?
    func markWhatsNewPresented(version: WhatsNew.Version)
    func removeAllPresentationMarks()
}

// MARK: LiveWhatsNewService

final class LiveWhatsNewService {
    private let versionStore: NSUbiquitousKeyValueWhatsNewVersionStore
    private let whatsNewEnvironment: WhatsNewEnvironment

    init(
        versionStore: NSUbiquitousKeyValueWhatsNewVersionStore = .init(),
        whatsNewCollection: WhatsNewCollection
    ) {
        self.versionStore = versionStore
        self.whatsNewEnvironment = WhatsNewEnvironment(
            versionStore: versionStore,
            whatsNewCollection: whatsNewCollection
        )
    }
}

extension LiveWhatsNewService: WhatsNewService {
    func whatsNew() -> WhatsNew? {
        whatsNewEnvironment.whatsNew()
    }

    func markWhatsNewPresented(version: WhatsNew.Version) {
        versionStore.save(presentedVersion: version)
    }

    func removeAllPresentationMarks() {
        versionStore.removeAll()
    }
}

// MARK: - Dependency

extension DependencyValues {
    var whatsNewService: any WhatsNewService {
        get { self[WhatsNewServiceKey.self] }
        set { self[WhatsNewServiceKey.self] = newValue }
    }
}

private enum WhatsNewServiceKey: DependencyKey {
    static let liveValue: any WhatsNewService = LiveWhatsNewService(whatsNewCollection: [
        .version300,
    ])
    static let previewValue: any WhatsNewService = WhatsNewServiceMock()
}

// MARK: - Mock

final class WhatsNewServiceMock: WhatsNewService {
    func whatsNew() -> WhatsNew? { nil }
    func markWhatsNewPresented(version: WhatsNew.Version) {}
    func removeAllPresentationMarks() {}
}
