import Foundation

final class WhatsNewScreen {
    struct Item {
        let imageName: String
        let title: String
        let description: String
    }

    var items: [Item] {
        logToShow.flatMap { $0.1 }
    }

    init(storage: UserDefaults) {
        self.storage = storage
    }

    func didShow() {
        lastShownVersion = logToShow.first?.0
    }

    static let log: [ShortAppVersion: [Item]] = [
        "2.2.2": [
            Item(
                imageName: "paperplane.fill",
                title: "Группа поддержки в Telegram",
                description: """
                    На экране "О приложении" появилась кнопка которая ведет в чат Telegram.
                    Заходите, но не забудьте согласовать это с администрацией своего района!
                    "Массовое онлайн мероприятие организованное по средствам https"
                    """
            )
        ],
        "2.2.0": [
            Item(
                imageName: "person.crop.circle",
                title: "Фото преподавателя",
                description: """
                    Теперь вы сможете узнавать преподавателя в лицо, даже если прогуляли все пары!
                    Никаких больше неловких молчаний, не нужно называть преподавателя "Извините"
                    """
            )
        ],
        "2.1.0": [
            Item(
                imageName: "rectangle.3.offgrid.fill",
                title: "Виджеты iOS 14.0!",
                description: """
                    Прямо из печки, свежие, неповторимые Виджеты написанные на SwiftUI!
                    Спешите добавить их на рабочий стол, пока я их не поломал и не удалил
                    Доступны в 3х размерах:
                    маленький - для самых маленьких
                    побольше - для крепких середнячков
                    самый большой - для здоровяков
                    """
            )
        ]
    ]

    private var logToShow: [(ShortAppVersion, [Item])] {
        let log = Self.log.sorted { $0.0 > $1.0 }
        guard let previousVersion = lastShownVersion else { return log }
        return Array(log.prefix { previousVersion < $0.0 })
    }

    private var lastShownVersion: ShortAppVersion? {
        get { storage.string(forKey: lastShownVersionKey).map(ShortAppVersion.init(_:)) }
        set { storage.set(newValue?.description, forKey: lastShownVersionKey) }
    }

    private let storage: UserDefaults
    private let lastShownVersionKey = "whats-new.last-shown-version"
}

extension ShortAppVersion: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major < rhs.major { return true }
        guard lhs.major == rhs.major else { return false }

        if lhs.minor < rhs.minor { return true }
        guard lhs.minor == rhs.minor else { return false }

        return lhs.patch < rhs.patch
    }
}
