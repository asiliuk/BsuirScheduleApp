#if DEBUG
import SwiftUI
import FrameUp
import ScheduleCore

public struct ScheduleWidgetPreviews: View {
    let dateStyle = Date.FormatStyle(date: .numeric, time:.omitted, locale: Locale(identifier: "ru_RU"))
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    public init() {}

    public var body: some View {
        ZStack {
            VStack {
                Spacer()
                Spacer()

                let widgetsText = Text("screen.widgetPreview.widgets")
                    .fontWeight(.heavy).foregroundColor(.purple)

                Text("screen.widgetPreview.message\(widgetsText)")
                    .font(.system(size: horizontalSizeClass == .regular ? 50 : 35))
                    .fontWeight(.medium)
                    .frame(maxWidth: 600)
                    .padding(.horizontal, 25)
                    .rotationEffect(.degrees(-6))

                Spacer()

                HStack(spacing: 22) {
                    VStack(spacing: 22) {
                        HStack(spacing: 22) {
                            WidgetDemoFrame(.small) { size, cornerRadius in
                                ScheduleWidgetEntrySmallView(
                                    config: .group151004,
                                    date: try! dateStyle.parse("01.09.2023")
                                )
                            }

                            WidgetDemoFrame(.small) { size, cornerRadius in
                                ScheduleWidgetEntrySmallView(
                                    config: .lectorMarina,
                                    date: try! dateStyle.parse("01.09.2023")
                                )
                            }
                        }

                        WidgetDemoFrame(.medium) { size, cornerRadius in
                            ScheduleWidgetEntryMediumView(
                                config: .group010101,
                                date: try! dateStyle.parse("04.09.2023")
                            )
                        }
                    }

                    if horizontalSizeClass == .regular {
                        WidgetDemoFrame(.large) { size, cornerRadius in
                            ScheduleWidgetEntryLargeView(
                                config: .group151003,
                                date: try! dateStyle.parse("04.09.2023")
                            )
                        }
                    }
                }

                Spacer()

                FakeDock()
                    .frame(maxWidth: 500)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { BackgroundGradient() }
            .environmentObject(PairFormDisplayService(
                storage: .mock(suiteName: "ScheduleWidgetPreviews"),
                widgetService: .noop
            ))
            .edgesIgnoringSafeArea(.all)
            .persistentSystemOverlays(.hidden)
        }
    }
}

// MARK: - Home UI

private struct FakeDock: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 35, style: .continuous)
            .fill(Material.thin)
            .frame(height: 100)
            .overlay {
                HStack {
                    FakeAppIcont(color: .green).frame(maxWidth: .infinity)
                    FakeAppIcont(color: .white).frame(maxWidth: .infinity)
                    FakeAppIcont(color: .mint).frame(maxWidth: .infinity)
                    FakeAppIcont(color: .indigo).frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
            }
            .opacity(0.4)
    }
}

private struct FakeAppIcont: View {
    let color: Color
    var dimension: CGFloat = 64
    var name: String? = nil

    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: dimension / 4.3, style: .continuous)
                .fill(color)
                .frame(width: dimension, height: dimension)
            if let name {
                Text(name)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .medium))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 0)
            }
        }
    }
}

// MARK: - Background

private struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [.purple, .indigo, .cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.5)
        .edgesIgnoringSafeArea(.all)
    }
}
// MARK: - Mocked Data

private extension ScheduleWidgetConfiguration {
    static let group010101 = ScheduleWidgetConfiguration(
        title: "010101",
        content: .pairs(
            passed: [
                PairViewModel(
                    from: "15:50",
                    to: "17:10",
                    interval: "15:50-17:10",
                    form: .lecture,
                    subject: "ПИСПБ",
                    subjectFullName: "ПИСПБ",
                    auditory: "613-2 к",
                    note: "(с 04.09-по 18.12)",
                    progress: .init(constant: 1)
                )
            ],
            upcoming: [
                PairViewModel(
                    from: "17:25",
                    to: "18:45",
                    interval: "17:25-18:45",
                    form: .lecture,
                    subject: "БПП",
                    subjectFullName: "БПП",
                    auditory: "615-2 к",
                    note: "(с 04.09-по 11.12)"
                ),
                PairViewModel(
                    from: "19:00",
                    to: "20:20",
                    interval: "19:00-20:20",
                    form: .lecture,
                    subject: "БПП",
                    subjectFullName: "БПП",
                    auditory: "615-2 к",
                    note: "(с 04.09-по 11.12)"
                ),
            ]
        )
    )

    static let group151004 = ScheduleWidgetConfiguration(
        title: "151004",
        content: .pairs(
            passed: [
                PairViewModel(
                    from: "09:00",
                    to: "10:20",
                    interval: "09:00-10:20",
                    form: .practice,
                    subject: "СпецП",
                    subjectFullName: "СпецП",
                    auditory: nil,
                    note: "(с 01.09-по 15.12)",
                    progress: .init(constant: 1)
                ),
                PairViewModel(
                    from: "10:35",
                    to: "11:55",
                    interval: "10:35-11:55",
                    form: .practice,
                    subject: "СпецП",
                    subjectFullName: "СпецП",
                    auditory: nil,
                    note: "(с 01.09-по 15.12)",
                    progress: .init(constant: 1)
                ),
            ],
            upcoming: [
                PairViewModel(
                    from: "12:25",
                    to: "13:45",
                    interval: "12:25-13:45",
                    form: .practice,
                    subject: "СпецП",
                    subjectFullName: "СпецП",
                    auditory: nil,
                    note: "(с 01.09-по 15.12)",
                    progress: .init(constant: 0.5)
                ),
                PairViewModel(
                    from: "14:00",
                    to: "15:20",
                    interval: "14:00-15:20",
                    form: .practice,
                    subject: "СпецП",
                    subjectFullName: "СпецП",
                    auditory: nil,
                    note: "(с 01.09-по 15.12)"
                ),
            ]
        )
    )

    static let group151003 = ScheduleWidgetConfiguration(
        title: "151003",
        content: .pairs(
            passed: [
                PairViewModel(
                    from: "09:00",
                    to: "10:20",
                    interval: "09:00-10:20",
                    form: .lecture,
                    subject: "РиАТ",
                    subjectFullName: "РиАТ",
                    auditory: "209-4 к",
                    progress: .init(constant: 1)
                ),
                PairViewModel(
                    from: "10:35",
                    to: "11:55",
                    interval: "10:35-11:55",
                    form: .lecture,
                    subject: "ВТ",
                    subjectFullName: "ВТ",
                    auditory: "209-4 к",
                    progress: .init(constant: 1)
                ),
            ],
            upcoming: [
                PairViewModel(
                    from: "12:25",
                    to: "13:45",
                    interval: "12:25-13:45",
                    form: .practice,
                    subject: "МиАПР",
                    subjectFullName: "МиАПР",
                    auditory: "213б-4 к",
                    subgroup: 1,
                    progress: .init(constant: 0.5)
                ),
                PairViewModel(
                    from: "12:25",
                    to: "13:45",
                    interval: "12:25-13:45",
                    form: .practice,
                    subject: "ВТ",
                    subjectFullName: "ВТ",
                    auditory: "316-5 к",
                    subgroup: 2,
                    progress: .init(constant: 0.5)
                ),
                PairViewModel(
                    from: "14:00",
                    to: "15:20",
                    interval: "14:00-15:20",
                    form: .practice,
                    subject: "МиАПР",
                    subjectFullName: "МиАПР",
                    auditory: "213б-4 к",
                    subgroup: 2
                ),
                PairViewModel(
                    from: "14:00",
                    to: "15:20",
                    interval: "14:00-15:20",
                    form: .practice,
                    subject: "ВТ",
                    subjectFullName: "ВТ",
                    auditory: "316-5 к",
                    subgroup: 1
                ),
            ]
        )
    )

    static let lectorMarina = ScheduleWidgetConfiguration(
        title: "МаринаИМ",
        content: .pairs(
            passed: [
                PairViewModel(
                    from: "09:00",
                    to: "10:20",
                    interval: "09:00-10:20",
                    form: .lab,
                    subject: "АиСД",
                    subjectFullName: "АиСД",
                    auditory: "210-4 к",
                    note: "(с 04.09-по 25.12)",
                    progress: .init(constant: 1)
                ),
            ],
            upcoming: [
                PairViewModel(
                    from: "12:25",
                    to: "13:45",
                    interval: "12:25-13:45",
                    form: .lab,
                    subject: "МиАПР",
                    subjectFullName: "МиАПР",
                    auditory: "213б-4 к",
                    note: "(с 04.09-по 11.12)",
                    subgroup: 1,
                    progress: .init(constant: 0.5)
                ),
                PairViewModel(
                    from: "14:00",
                    to: "15:20",
                    interval: "14:00-15:20",
                    form: .lab,
                    subject: "МиАПР",
                    subjectFullName: "МиАПР",
                    auditory: "213б-4 к",
                    note: "(с 04.09-по 11.12)",
                    subgroup: 2
                ),
            ]
        )
    )
}

struct ScheduleWidgetPreviews_Preview: PreviewProvider {
    static var previews: some View {
        ScheduleWidgetPreviews()
    }
}
#endif
