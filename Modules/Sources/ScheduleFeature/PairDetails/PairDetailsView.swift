import SwiftUI
import BsuirUI
import BsuirApi
import XCTestDynamicOverlay
import ComposableArchitecture
import ScheduleCore

struct PairDetailsView: View {
    struct ViewState: Equatable {
        var title: String

        var lecturers: [Employee]
        var groups: [String]

        var fullName: String?
        var timeInterval: String
        var date: String
        var formName: LocalizedStringKey
        var subgroup: String
        var auditory: String
        var weeks: String
        var notes: String?
        var photoPreview: URL?

        init(_ state: PairDetailsFeature.State) {
            self.title = state.pair.subject ?? "--"

            self.lecturers = (state.rowDetails != .groups) ? state.pair.lecturers : []
            self.groups = (state.rowDetails != .lecturers) ? state.pair.groups : []

            self.fullName = state.pair.subjectFullName
            self.timeInterval = state.pair.interval

            self.date =  switch state.rowDay {
            case .date(let date):
                date?.formatted(.pairDate) ?? "--"
            case .weekday(let weekDay):
                weekDay.localizedName(in: .current).capitalized
            }

            self.formName = state.pair.form.name
            self.subgroup = state.pair.subgroup == 0 ? "--" : String(describing: state.pair.subgroup)
            self.auditory = state.pair.auditory ?? "--"
            self.weeks = state.pair.weeks ?? "--"
            self.notes = state.pair.note
            self.photoPreview = state.photoPreview
        }
    }

    let store: StoreOf<PairDetailsFeature>

    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: ViewState.init) { viewStore in
                List {
                    if !viewStore.lecturers.isEmpty {
                        Section("screen.pairDetails.lecturers.section.title") {
                            ForEach(viewStore.lecturers, id: \.id) { employee in
                                LecturerCell(
                                    photo: employee.photoLink,
                                    name: employee.fio
                                ) {
                                    viewStore.send(.lectorTapped(employee))
                                } onPhotoTap: {
                                    viewStore.send(.lectorPhotoTapped(employee))
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }

                    if !viewStore.groups.isEmpty {
                        Section("screen.pairDetails.groups.section.title") {
                            ForEach(viewStore.groups, id: \.self) { group in
                                GroupCell(name: group) { viewStore.send(.groupTapped(group)) }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }

                    Section {
                        if let fullName = viewStore.fullName {
                            Text(fullName).font(.title3.bold())
                        }

                        LabeledContent("screen.pairDetails.details.time.title") {
                            Text(viewStore.timeInterval)
                        }
                        LabeledContent("screen.pairDetails.details.day.title") {
                            Text(viewStore.date)
                        }
                        LabeledContent("screen.pairDetails.details.type.title") {
                            Text(viewStore.formName)
                        }
                        LabeledContent("screen.pairDetails.details.subgroup.title") {
                            Text(viewStore.subgroup)
                        }
                        LabeledContent("screen.pairDetails.details.auditory.title") {
                            Text(viewStore.auditory)
                        }
                        LabeledContent("screen.pairDetails.details.weeks.title") {
                            Text(viewStore.weeks)
                        }

                        if let notes = viewStore.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("screen.pairDetails.details.notes.title")
                                Text(notes).foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("Детали")
                    }
                }
                .navigationTitle(viewStore.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    CloseModalToolbarItem {
                        viewStore.send(.closeButtonTapped)
                    }
                }
                .photoPreview(viewStore.binding(get: \.photoPreview, send: { .setPhotoPreview($0) }))
            }
        }
        .presentationDetents([.fraction(0.4), .large])
        .presentationDragIndicator(.hidden)
        .scrollIndicators(.never)
        .frame(idealWidth: 400, idealHeight: 600)
    }
}

private struct LecturerCell: View {
    let photo: URL?
    let name: String
    var onTap: () -> Void = unimplemented("LecturerCell.onTap")
    var onPhotoTap: () -> Void = unimplemented("LecturerCell.onPhotoTap")

    var body: some View {
        Button(action: onTap) {
            HStack {
                Button(action: onPhotoTap) { Avatar(url: photo, baseSize: 60) }
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.primary, Color(uiColor: .secondarySystemGroupedBackground))
                    }

                Text(name)

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.primary)
        }
    }
}

private struct GroupCell: View {
    let name: String
    var onTap: () -> Void = unimplemented("LecturerCell.onTap")

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(name)

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.primary)
        }
    }
}

private extension PairViewModel {
    static let preview = PairViewModel(
        from: "10:30",
        to: "12:00",
        interval: "10:30-12:00",
        form: .lecture,
        subject: "ПиРИС",
        subjectFullName: "Проектирование и разработка информационных систем",
        auditory: "157к 2",
        note: "Это какая-то совершенно не нужная, но очень длинная и важная заметка",
        weeks: "1,3",
        subgroup: 2,
        lecturers: [
            Employee(
                id: 1,
                urlId: "1",
                firstName: "Артём",
                middleName: "Александрович",
                lastName: "Фещенко",
                photoLink: URL(string: "https://iis.bsuir.by/api/v1/employees/photo/515644")
            ),
            Employee(
                id: 2,
                urlId: "2",
                firstName: "Андрей",
                middleName: "Игоревич",
                lastName: "Бересневич",
                photoLink: URL(string: "https://iis.bsuir.by/api/v1/employees/photo/500023")
            )
        ],
        groups: [
            "151004",
            "151005",
        ]
    )
}

private struct PairDetailsViewPreview: View {
    @State var isDetailsShown: Bool = true

    var body: some View {
        Button("Show") {
            isDetailsShown.toggle()
        }
        .sheet(isPresented: $isDetailsShown) {
            PairDetailsView(store: Store(
                initialState: PairDetailsFeature.State(
                    pair: .preview,
                    rowDetails: .lecturers,
                    rowDay: .date(nil)
                ),
                reducer: {}
            ))
        }
    }
}

#Preview("Sheet") {
    PairDetailsViewPreview()
}

#Preview("Fullscreen") {
    PairDetailsView(store: Store(
        initialState: PairDetailsFeature.State(
            pair: .preview,
            rowDetails: .lecturers,
            rowDay: .date(nil)
        ),
        reducer: {}
    ))
}
