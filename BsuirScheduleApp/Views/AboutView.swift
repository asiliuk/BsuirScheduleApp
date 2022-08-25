import SwiftUI
import Foundation
import BsuirUI
import BsuirCore

struct AboutView: View {
    @ObservedObject var screen: AboutScreen

    var body: some View {
        List {
            Section(header: Text("screen.about.colors.section.header")) {
                ForEach(PairViewForm.allCases, id: \.self) { form in
                    PairTypeView(name: form.name, form: form)
                }
            }

            Section(header: Text("screen.about.pair.section.header")) {
                PairCell(
                    from: "screen.about.pairCell.from",
                    to: "screen.about.pairCell.to",
                    subject: "screen.about.pairCell.subject",
                    weeks: "screen.about.pairCell.weeks",
                    subgroup: "screen.about.pairCell.subgroup",
                    auditory: "screen.about.pairCell.auditory",
                    note: "screen.about.pairCell.note",
                    form: .practice,
                    progress: PairProgress(constant: 0.5),
                    details: EmptyView()
                )
                .fixedSize(horizontal: false, vertical: true)
                .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
                .accessibility(label: Text("screen.about.pair.accessibility.label"))
            }

            AppIconPicker(bundle: bundle)

            Section(header: Text("screen.about.about.section.header")) {
                Text("screen.about.about.section.version.\(bundle.fullVersion.description)")
                GithubButton()
                TelegramButton()
            }

            Section(header: Text("screen.about.data.section.header")) {
                Button("screen.about.data.section.clearCache.button") {
                    screen.clearCache()
                }
                .alert(isPresented: $screen.isCacheCleared) {
                    Alert(
                        title: Text("screen.about.clearCache.alert.title"),
                        message: Text("screen.about.clearCache.alert.message")
                    )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("screen.about.navigation.title")
    }

    private let bundle = Bundle.main

}

private struct GithubButton: View {
    var body: some View {
        LinkButton(
            title: "GitHub",
            url: URL(string: "https://github.com/asiliuk/BsuirScheduleApp"),
            event: .githubOpened
        )
    }
}

private struct TelegramButton: View {
    var body: some View {
        LinkButton(
            title: "Telegram",
            url: URL(string: "https://t.me/bsuirschedule"),
            event: .telegramOpened
        )
    }
}

private struct LinkButton: View {
    let title: LocalizedStringKey
    let url: URL?
    let event: ReviewRequestService.MeaningfulEvent
    @Environment(\.openURL) var openURL
    @Environment(\.reviewRequestService) var reviewRequestService

    var body: some View {
        Button {
            guard let url = url else { return }
            reviewRequestService?.madeMeaningfulEvent(event)
            openURL(url)
        } label: {
            Text(title).underline()
        }
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
