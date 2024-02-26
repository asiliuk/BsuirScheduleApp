import SwiftUI
import BsuirUI
import BsuirApi
import XCTestDynamicOverlay
import ComposableArchitecture
import ScheduleCore

struct PairDetailsView: View {
    @Perception.Bindable var store: StoreOf<PairDetailsFeature>

    var body: some View {
        NavigationStack {
            WithPerceptionTracking {
                List {
                    PairDetailsLecturersSectionView(store: store)
                    PairDetailsGroupsSectionView(store: store)
                    PairDetailsSectionView(store: store)
                }
                .navigationTitle(store.pair.subject ?? "--")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    CloseModalToolbarItem {
                        store.send(.closeButtonTapped)
                    }
                }
                .photoPreview($store.photoPreview.sending(\.setPhotoPreview))
            }
        }
        .presentationDetents([.fraction(0.4), .large])
        .presentationDragIndicator(.hidden)
        .scrollIndicators(.never)
        .frame(idealWidth: 400, idealHeight: 600)
    }
}

private struct PairDetailsLecturersSectionView: View {
    let store: StoreOf<PairDetailsFeature>

    var body: some View {
        WithPerceptionTracking {
            if store.rowDetails != .groups {
                Section("screen.pairDetails.lecturers.section.title") {
                    ForEach(store.pair.lecturers, id: \.id) { employee in
                        LecturerCell(
                            photo: employee.photoLink,
                            name: employee.fio
                        ) {
                            store.send(.lectorTapped(employee))
                        } onPhotoTap: {
                            store.send(.lectorPhotoTapped(employee))
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
    }
}

private struct PairDetailsGroupsSectionView: View {
    let store: StoreOf<PairDetailsFeature>

    var body: some View {
        WithPerceptionTracking {
            if store.rowDetails != .lecturers {
                Section("screen.pairDetails.groups.section.title") {
                    ForEach(store.pair.groups, id: \.self) { group in
                        GroupCell(name: group) { store.send(.groupTapped(group)) }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
    }
}

private struct PairDetailsSectionView: View {
    let store: StoreOf<PairDetailsFeature>

    var body: some View {
        Section {
            WithPerceptionTracking {
                if let fullName = store.pair.subjectFullName {
                    Text(fullName).font(.title3.bold())
                }

                LabeledContent("screen.pairDetails.details.time.title") {
                    Text(store.pair.interval)
                }
                LabeledContent("screen.pairDetails.details.day.title") {
                    switch store.rowDay {
                    case .date(let date):
                        Text(date?.formatted(.pairDate) ?? "--")
                    case .weekday(let weekDay):
                        Text(weekDay.localizedName(in: .current).capitalized)
                    }
                }
                LabeledContent("screen.pairDetails.details.type.title") {
                    Text(store.pair.form.name)
                }
                LabeledContent("screen.pairDetails.details.subgroup.title") {
                    Text(store.pair.subgroup == 0 ? "--" : store.pair.subgroup.description)
                }
                LabeledContent("screen.pairDetails.details.auditory.title") {
                    Text(store.pair.auditory ?? "--")
                }
                LabeledContent("screen.pairDetails.details.weeks.title") {
                    Text(store.pair.weeks ?? "--")
                }

                if let notes = store.pair.note {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("screen.pairDetails.details.notes.title")
                        Text(notes).foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            Text("screen.pairDetails.details.header.title")
        }
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
