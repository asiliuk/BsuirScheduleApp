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
        @State var photoTapped = false
        @State var cellTapped = false

        var body: some View {
            Button(action: { cellTapped.toggle() }) {
                HStack {
                    Button {
                        photoTapped.toggle()
                    } label: {
                        Avatar(url: URL(string: image), baseSize: 60)
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.primary, Color(uiColor: .secondarySystemGroupedBackground))
                            }
                    }
                    VStack(alignment: .leading) {
                        Text(name)
                        degree.map(Text.init(verbatim:))?
                            .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.forward")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
        }
    }

    struct PairBottomDetails<Content: View>: View {
        @State var detent: PresentationDetent = .height(250)
        @ViewBuilder var content: Content

        var body: some View {
            ModalNavigationStack(showCloseButton: detent == .large) {
                content
            }
            .presentationDetents([.height(250), .large], selection: $detent)
            .presentationDragIndicator(.hidden)
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
                PairBottomDetails {
                    List {
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
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                        Section("Детали") {
                            Text("Проектирование и разработка информационных систем")
                                .font(.title3.bold())

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
                    }
                    .padding(.top, -24)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                          ToolbarItem(placement: .principal) {
                              VStack {
                                  Text("ПиРИС").font(.headline)
                                  Text((Date.now..<Date.now.addingTimeInterval(3600)).formatted())
                                      .font(.subheadline)
                                      .foregroundColor(.secondary)
                              }
                          }
                      }
                }
            }
        }
    }

    static var previews: some View {
        TestView()
    }
}
