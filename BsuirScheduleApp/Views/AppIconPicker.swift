import SwiftUI


struct AppIconPicker: View {
    let bundle: Bundle
    let application: UIApplication

    init(bundle: Bundle, application: UIApplication) {
        self.bundle = bundle
        self.application = application
        self._icon = State(initialValue: application.alternateIconName.flatMap(AppIcon.init(name:)) ?? .standard)
    }

    var body: some View {
        if application.supportsAlternateIcons {
            Section(header: Text("Внешний вид")) {
                Picker(selection: $icon, label: Text("Иконка")) {
                    ForEach(AppIcon.allCases) { icon in
                        HStack {
                            AppIconView(icon: icon, bundle: bundle)
                            Text(icon.title)
                        }
                    }
                }
            }
            .onChange(of: icon) { icon in
                application.setAlternateIconName(icon.name) { error in
                    guard error == nil else { return }
                    alert = AlertIdentifier(appIcon: icon)
                }
            }
            .alert(item: $alert) { alert in
                switch alert {
                case .goodIconChoice:
                    return Alert(title: Text("Отличный выбор!"), message: Text("Жыве Беларусь!"))
                case .badIconChoice:
                    return Alert(title: Text("Ну здравствуйте"), message: Text("Нас ждет очень серьезный разговор по поводу вашего выбора"))
                }
            }
        }
    }

    private enum AlertIdentifier: Identifiable {
        var id: Self { self }
        case goodIconChoice
        case badIconChoice

        init?(appIcon: AppIcon) {
            switch appIcon {
            case .resist: self = .goodIconChoice
            case .dad: self = .badIconChoice
            default: return nil
            }
        }
    }

    @State private var alert: AlertIdentifier?
    @State private var icon: AppIcon
}

private struct AppIconView: View {
    let icon: AppIcon
    let bundle: Bundle
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 34

    var body: some View {
        icon.image(in: bundle)
            .map { Image(uiImage: $0).resizable() }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: (8 / 34) * size, style: .continuous))
    }
}

private enum AppIcon: CaseIterable, Identifiable {
    var id: Self { self }
    case standard
    case dark
    case nostalgia
    case resist
    case dad

    init?(name: String) {
        switch name {
        case "AppIconDark": self = .dark
        case "AppIconNostalgia": self = .nostalgia
        case "AppIconResist": self = .resist
        case "AppIconDad": self = .dad
        default: return nil
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .standard: return "Стандартная"
        case .dark: return "Темная"
        case .nostalgia: return "Ностальгия"
        case .resist: return "❤️✊✌️"
        case .dad: return "Я твой баця"
        }
    }

    var name: String? {
        switch self {
        case .standard: return nil
        case .dark: return "AppIconDark"
        case .nostalgia: return "AppIconNostalgia"
        case .resist: return "AppIconResist"
        case .dad: return "AppIconDad"
        }
    }

    func image(in bundle: Bundle) -> UIImage? {
        guard let name = name else { return bundle.appIcon }
        return UIImage(named: name)
    }
}

private extension Bundle {
    var appIcon: UIImage? {
        guard
            let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last
        else { return nil }

        return UIImage(named: lastIcon)
    }
}
