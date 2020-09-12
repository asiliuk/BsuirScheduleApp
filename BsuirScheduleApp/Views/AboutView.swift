import SwiftUI
import Foundation

struct AboutView: View {
    var body: some View {
        List {
            Section(header: Text("Цвета")) {
                ForEach(PairCell.Form.allCases, id: \.self) { form in
                    PairTypeView(name: form.name, color: form.color)
                }
            }

            Section(header: Text("Как выглядит пара")) {
                PairCell(
                    from: "начало",
                    to: "конец",
                    subject: "Предмет",
                    weeks: "неделя",
                    note: "Кабинет - корпус",
                    form: .practice,
                    progress: PairProgress(constant: 0.5)
                )
                .fixedSize(horizontal: false, vertical: true)
                .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                .accessibility(label: Text("Визуальное отображение пары с подписанными элементами"))
            }

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
            }

            Section(header: Text("О приложении")) {
                Text("Версия \(bundle.version)")
                GithubButton()
            }
        }
        .onChange(of: icon) { icon in
            application.setAlternateIconName(icon.name) { error in
                guard error == nil else { return }
                alert = AlertIdentifier(appIcon: icon)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Информация")
        .alert(item: $alert) { alert in
            switch alert {
            case .goodIconChoice:
                return Alert(title: Text("Отличный выбор!"), message: Text("Жыве Беларусь!"))
            case .badIconChoice:
                return Alert(title: Text("Ну здравствуйте"), message: Text("Нас ждет очень серьезный разговор по поводу вашего выбора"))
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
    private let application = UIApplication.shared
    private let bundle = Bundle.main
    @State private var icon: AppIcon = .standard
}

private struct AppIconView: View {
    let icon: AppIcon
    let bundle: Bundle

    var body: some View {
        icon.image(in: bundle)
            .map { Image(uiImage: $0).resizable() }
            .frame(width: 34, height: 34)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private enum AppIcon: CaseIterable, Identifiable {
    var id: Self { self }
    case standard
    case dark
    case nostalgia
    case resist
    case dad

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

private struct GithubButton: View {
    var body: some View {
        Button(action: openURL) {
            Text("GitHub").underline()
        }
    }

    func openURL() {
        guard let url = URL(string: "https://github.com/asiliuk/BsuirScheduleApp") else { return }
        UIApplication.shared.open(url)
    }
}

private extension Bundle {
    var version: String {
        "\(shortVersion)(\(buildNumber))"
    }

    var shortVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

struct PairTypeView: View {
    var name: LocalizedStringKey
    var color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .foregroundColor(color)
                .frame(width: 30, height: 30)
            Text(name)
        }
    }
}

extension PairCell.Form {
    var name: LocalizedStringKey {
        switch self {
        case .lecture: return "Лекция"
        case .lab: return "Лабораторная работа"
        case .practice: return "Практическая работа"
        case .exam: return "Экзамен"
        case .unknown: return "Неизвестно"
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { AboutView() }
        NavigationView { AboutView().colorScheme(.dark) }
    }
}
