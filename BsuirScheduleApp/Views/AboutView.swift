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

            Section(header: Text("Пара")) {
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
            }

            Section(header: Text("О приложении")) {
                Text("Версия \(Bundle.main.version)")
                GithubButton()
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Информация")
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

private extension PairCell.Form {
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
        AboutView()
        AboutView().colorScheme(.dark)
    }
}
