import WhatsNewKit
import Dependencies

public protocol WhatsNewService {
    func whatsNew() -> WhatsNew?
    func markWhatsNewPresented(version: WhatsNew.Version)
    func removeAllPresentationMarks()
}

// MARK: - RemovableWhatsNewVersionStore

protocol RemovableWhatsNewVersionStore {
    func removeAll()
}

extension InMemoryWhatsNewVersionStore: RemovableWhatsNewVersionStore {}
extension NSUbiquitousKeyValueWhatsNewVersionStore: RemovableWhatsNewVersionStore {}
extension UserDefaultsWhatsNewVersionStore: RemovableWhatsNewVersionStore {}

// MARK: LiveWhatsNewService

final class LiveWhatsNewService {
    private let versionStore: RemovableWhatsNewVersionStore & WhatsNewVersionStore
    private let whatsNewEnvironment: WhatsNewEnvironment

    init(
        versionStore: RemovableWhatsNewVersionStore & WhatsNewVersionStore,
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
    static let liveValue: any WhatsNewService = LiveWhatsNewService(
        versionStore: {
            #if DEBUG
            InMemoryWhatsNewVersionStore()
            #else
            CloudKitWhatsNewVersionStore()
            #endif
        }(),
        whatsNewCollection: [
            .version310,
            .version300,
        ]
    )

    static let previewValue: any WhatsNewService = LiveWhatsNewService(
        versionStore: InMemoryWhatsNewVersionStore(),
        whatsNewCollection: []
    )
}
