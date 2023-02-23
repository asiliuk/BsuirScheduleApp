import SwiftUI
import BsuirCore
import SettingsFeature
import GroupsFeature
import LecturersFeature
import EntityScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils

struct CompactRootView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: \.selection) { viewStore in
            TabView(selection: viewStore.binding(get: { $0 }, send: AppFeature.Action.setSelection)) {

                PinnedTabView(
                    store: store.scope(
                        state: \.pinnedTab,
                        action: AppFeature.Action.pinnedTab
                    )
                )
                .tag(CurrentSelection.pinned)

                GroupsFeatureTab(
                    store: store.scope(
                        state: \.groups,
                        action: AppFeature.Action.groups
                    )
                )
                .tag(CurrentSelection.groups)

                LecturersFeatureTab(
                    store: store.scope(
                        state: \.lecturers,
                        action: AppFeature.Action.lecturers
                    )
                )
                .tag(CurrentSelection.lecturers)

                SettingsFeatureTab(
                    store: store.scope(
                        state: \.settings,
                        action: AppFeature.Action.settings
                    )
                )
                .tag(CurrentSelection.settings)
            }
        }
    }
}

private struct GroupsFeatureTab: View {
    let store: StoreOf<GroupsFeature>

    var body: some View {
        NavigationStack {
            GroupsFeatureView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem { GroupsLabel() }
    }
}

private struct LecturersFeatureTab: View {
    let store: StoreOf<LecturersFeature>

    var body: some View {
        NavigationStack {
            LecturersFeatureView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem { LecturersLabel() }
    }
}

private struct SettingsFeatureTab: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        WithViewStore(store, observe: \.path) { viewStore in
            NavigationStack(path: viewStore.binding(send: { .view(.setPath($0)) })) {
                SettingsFeatureView(store: store)
                    .navigationBarTitleDisplayMode(.inline)

            }
        }
        .tabItem { SettingsLabel() }
    }
}
import BsuirUI

struct SomePreview: PreviewProvider {
    struct LectorCell: View {
        let image: String
        let name: String
        let degree: String?

        var body: some View {
            HStack {
                Avatar(url: URL(string: image), baseSize: 80)
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                    degree.map(Text.init(verbatim:))?
                        .font(.caption)
                }
            }
        }
    }
    struct TestView: View {
        @State var bottomSheetVisible = true

        var body: some View {
            Button("Show") {
                bottomSheetVisible.toggle()
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $bottomSheetVisible) {
                List {
                    Section {
                        Text("Проектирование и разработка информационных систем")
                            .font(.title2.bold())
                            .foregroundColor(.primary)

                        Text("Среда, 22 Февраля 2023\nС 16:00 До 17:00")
                            .font(.subheadline)
                            .padding(.top, 8)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(EmptyView())

                        Section {
                            LabeledContent("Тип") { Text("Лекция") }
                            LabeledContent("Подгруппы") { Text("--") }
                            LabeledContent("Аудитории") { Text("157к 2") }
                            LabeledContent("Дни") { Text("Чт, Пт") }
                            LabeledContent("Недели") { Text("1, 3") }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Заметки")
                                Text("Это какая-то совершенно не нужная, но очень длинная и важная заметка")
                                    .foregroundColor(.secondary)
                            }
                        }

                    Section {
                        LectorCell(
                            image: "https://iis.bsuir.by/api/v1/employees/photo/515644",
                            name: "Фещенко Артём Александрович",
                            degree: nil
                        )
                        LectorCell(
                            image: "https://iis.bsuir.by/api/v1/employees/photo/511968",
                            name: "Ролич Олег Чеславович",
                            degree: "кандидат технических наук"
                        )
                    }
                }
                .padding(.top, -32)
                .listStyle(.insetGrouped)
                .safeAreaInset(edge: .top) {
                    Color(uiColor: .systemGroupedBackground)
                        .frame(height: 16)
                }
                .presentationDetents([.height(200), .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    static var previews: some View {
        TestView()
    }
}
