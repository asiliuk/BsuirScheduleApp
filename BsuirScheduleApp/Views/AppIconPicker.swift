import SwiftUI


struct AppIconPicker: View {
    let bundle: Bundle
    let application: UIApplication = .shared
    @Environment(\.reviewRequestService) var reviewRequestService

    init(bundle: Bundle) {
        self.bundle = bundle
        self._icon = State(initialValue: application.alternateIconName.flatMap(AppIcon.init(name:)) ?? .standard)
    }

    var body: some View {
        if application.supportsAlternateIcons {
            Section(header: Text("Appearance")) {
                Picker(selection: $icon, label: Text("Icon")) {
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
                    reviewRequestService?.madeMeaningfulEvent(.appIconChanged)
                    alert = AlertIdentifier(appIcon: icon)
                }
            }
            .alert(item: $alert) { alert in
                switch alert {
                case .belarusIconChoice:
                    return Alert(title: Text("Excellent choice!"), message: Text("Long live Belarus!"))
                }
            }
        }
    }

    private enum AlertIdentifier: Identifiable {
        var id: Self { self }
        case belarusIconChoice

        init?(appIcon: AppIcon) {
            switch appIcon {
            case .resist, .national: self = .belarusIconChoice
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
    case national
    case ukrainian
    case pride

    init?(name: String) {
        switch name {
        case "AppIconDark": self = .dark
        case "AppIconNostalgia": self = .nostalgia
        case "AppIconResist": self = .resist
        case "AppIconNational": self = .national
        case "AppIconUkrainian": self = .ukrainian
        case "AppIconPride": self = .pride
        default: return nil
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .standard: return "Default"
        case .dark: return "Dark"
        case .nostalgia: return "Nostalgia"
        case .resist: return "❤️✊✌️"
        case .national: return "БЧБ"
        case .ukrainian: return "Ukrainian"
        case .pride: return "Pride"
        }
    }

    var name: String? {
        switch self {
        case .standard: return nil
        case .dark: return "AppIconDark"
        case .nostalgia: return "AppIconNostalgia"
        case .resist: return "AppIconResist"
        case .national: return "AppIconNational"
        case .ukrainian: return "AppIconUkrainian"
        case .pride: return "AppIconPride"
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
