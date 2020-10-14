import SwiftUI
import Foundation
import BsuirUI
import BsuirCore

struct AboutView: View {

    var body: some View {
        List {
            Section(header: Text("Цвета")) {
                ForEach(PairViewForm.allCases, id: \.self) { form in
                    PairTypeView(name: form.name, form: form)
                }
            }

            Section(header: Text("Как выглядит пара")) {
                PairCell(
                    from: "начало",
                    to: "конец",
                    subject: "Предмет",
                    weeks: "нед.",
                    subgroup: "подгр.",
                    auditory: "Кабинет - корпус",
                    note: "Комментарий",
                    form: .practice,
                    progress: PairProgress(constant: 0.5),
                    details: EmptyView()
                )
                .fixedSize(horizontal: false, vertical: true)
                .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                .accessibility(label: Text("Визуальное отображение пары с подписанными элементами"))
            }

            AppIconPicker(bundle: bundle, application: application)

            Section(header: Text("О приложении")) {
                Text("Версия \(bundle.version)")
                GithubButton(application: application)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Информация")
    }

    private let application = UIApplication.shared
    private let bundle = Bundle.main

}

private struct GithubButton: View {
    let application: UIApplication
    @Environment(\.reviewRequestService) var reviewRequestService

    var body: some View {
        Button(action: openURL) {
            Text("GitHub").underline()
        }
    }

    func openURL() {
        guard let url = URL(string: "https://github.com/asiliuk/BsuirScheduleApp") else { return }
        reviewRequestService?.madeMeaningfulEvent(.githubOpened)
        application.open(url)
    }
}

extension Bundle {
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
    var form: PairViewForm
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    var body: some View {
        HStack {
            Group {
                if differentiateWithoutColor {
                    form.shape
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                }
            }
            .foregroundColor(form.color)
            .frame(width: 30, height: 30)

            Text(name)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { AboutView() }
        NavigationView { AboutView().colorScheme(.dark) }
    }
}
