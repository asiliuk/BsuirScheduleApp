import SwiftUI

struct AllFavoritesView: View {
    @ObservedObject var screen: AllFavoritesScreen
    let openGroups: () -> Void

    var body: some View {
        Group {
            if screen.groups.isEmpty, screen.lecturers.isEmpty {
                placeholder
            } else {
                list
            }
        }
        .navigationTitle("Избранные")
    }

    private var placeholder: some View {
        EmptyState(
            image: Image(systemName: "hand.raised.fill"),
            title: "Ты не избранный, Нео",
            subtitle: "Выбери кого-нибудь другого",
            action: .init(
                title: "Веди меня!",
                action: openGroups
            )
        )
    }

    private var list: some View {
        List {
            if !screen.groups.isEmpty {
                Section(header: Text("Группы")) {
                    ForEach(screen.groups) { group in
                        NavigationLinkButton {
                            screen.selection = .group(group)
                        } label: {
                            Text(group.name)
                        }
                    }
                }
            }

            if !screen.lecturers.isEmpty {
                Section(header: Text("Преподаватели")) {
                    ForEach(screen.lecturers) { lecturer in
                        NavigationLinkButton {
                            screen.selection = .lecturer(lecturer)
                        } label: {
                            LecturerCell(lecturer: lecturer)
                        }
                    }
                }
            }
        }
        .navigation(item: $screen.selection) { selection in
            ScheduleView(screen: screen.screen(for: selection))
        }
        .listStyle(InsetGroupedListStyle())
    }
}
