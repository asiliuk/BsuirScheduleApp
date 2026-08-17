import SwiftUI
import BsuirUI
import BsuirApi
import XCTestDynamicOverlay
import ComposableArchitecture
import ScheduleCore

struct PairDetailsView: View {
    @Bindable var store: StoreOf<PairDetailsFeature>

    var body: some View {
        NavigationStack {
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
        .presentationDetents([.fraction(0.4), .large])
        .presentationDragIndicator(.hidden)
        .scrollIndicators(.never)
        .frame(idealWidth: 400, idealHeight: 600)
    }
}

private struct PairDetailsLecturersSectionView: View {
    let store: StoreOf<PairDetailsFeature>

    var body: some View {
        if store.rowDetails != .groups {
            Section("screen.pairDetails.lecturers.section.title") {
                ForEach(store.pair.lecturers, id: \.id) { employee in
                    LecturerCell(
                        photo: employee.actualPhotoLink,
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

private struct PairDetailsGroupsSectionView: View {
    let store: StoreOf<PairDetailsFeature>

    var body: some View {
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

private struct PairDetailsSectionView: View {
    let store: StoreOf<PairDetailsFeature>

    var body: some View {
        Section {
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
                if let weeks = store.pair.weeks {
                    WeekNumbersView(weeks: weeks)
                } else {
                    Text("--")
                }
            }

            if let notes = store.pair.note {
                VStack(alignment: .leading, spacing: 8) {
                    Text("screen.pairDetails.details.notes.title")
                    Text(notes).foregroundColor(.secondary)
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
                if let photo {
                    Button(action: onPhotoTap) { Avatar(url: photo, baseSize: 60) }
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.primary, Color(uiColor: .secondarySystemGroupedBackground))
                        }
                } else {
                    Avatar(url: photo, baseSize: 60)
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
                rank: nil,
                degree: nil,
                academicDepartment: nil,
                photoLink: URL(string: "https://iis.bsuir.by/api/v1/employees/photo/515644")
            ),
            Employee(
                id: 2,
                urlId: "2",
                firstName: "Андрей",
                middleName: "Игоревич",
                lastName: "Бересневич",
                rank: nil,
                degree: nil,
                academicDepartment: nil,
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

private struct WeekNumbersView: View {
    let weekNum: WeekNum

    init(weeks: String) {
        // I also do not like this solution
        // first we convert WeekNum to String on view model layer
        // then we decode it back here. But the answer is trivial: I need
        // PairView to accept String because in settings we show it with
        // placeholder data to explain how row works
        // So I do not have a time for a proper refactoring and this is easiest solution
        self.weekNum = weeks.split(separator: ",")
            .compactMap { Int($0) }
            .compactMap { WeekNum(weekNum: $0) }
            .reduce([]) { result, week in
                result.union(week)
            }
    }

    init(weekNum: WeekNum) {
        self.weekNum = weekNum
    }

    var body: some View {
        Text("""
        \(weekNumber(1, isSelected: weekNum.contains(.first)))\
        \(weekNumber(2, isSelected: weekNum.contains(.second)))\
        \(weekNumber(3, isSelected: weekNum.contains(.third)))\
        \(weekNumber(4, isSelected: weekNum.contains(.forth)))
        """)
    }

    func weekNumber(_ number: Int, isSelected: Bool) -> Text {
        let image = if isSelected {
            Image(systemName: "\(number).circle.fill")
        } else {
            Image("custom.\(number).circle.dotted")

        }
        return Text("\(image)").foregroundStyle(isSelected ? .secondary : .tertiary)
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
