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
                Text("Версия \(bundle.fullVersion.description)")
                GithubButton(application: application)
                TelegramButton(application: application)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Информация")
    }

    private let application = UIApplication.shared
    private let bundle = Bundle.main

}

private struct GithubButton: View {
    let application: UIApplication

    var body: some View {
        LinkButton(
            application: application,
            title: "GitHub",
            url: URL(string: "https://github.com/asiliuk/BsuirScheduleApp"),
            event: .githubOpened
        )
    }
}

private struct TelegramButton: View {
    let application: UIApplication

    var body: some View {
        LinkButton(
            application: application,
            title: "Telegram",
            url: URL(string: "https://t.me/bsuirschedule"),
            event: .telegramOpened
        )
    }
}

private struct LinkButton: View {
    let application: UIApplication
    let title: LocalizedStringKey
    let url: URL?
    let event: ReviewRequestService.MeaningfulEvent
    @Environment(\.reviewRequestService) var reviewRequestService

    var body: some View {
        Button(action: openURL) {
            Text(title).underline()
        }
    }

    func openURL() {
        guard let url = url else { return }
        reviewRequestService?.madeMeaningfulEvent(event)
        application.open(url)
    }
}

extension Bundle {
    var fullVersion: FullAppVersion {
        FullAppVersion(short: shortVersion, build: buildNumber)
    }

    var shortVersion: ShortAppVersion {
        ShortAppVersion(infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
    }

    var buildNumber: Int {
        Int(infoDictionary?["CFBundleVersion"] as? String ?? "") ?? 0
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
