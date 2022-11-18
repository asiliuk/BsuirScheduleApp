import SwiftUI

struct RegularRootView: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?
    @Binding var currentOverlay: CurrentOverlay?

    var body: some View {
        NavigationView {
            TabView(selection: $currentSelection) {
                // Placeholder
                // When in NavigationView first tab is not visible on iPad
                Text("Oops").opacity(0)

                GroupsView(store: state.groupsStore)
                    .tab(.groups)

                LecturersView(store: state.lecturersStore)
                    .tab(.lecturers)
            }
            .toolbar {
                Button {
                    currentOverlay = .about
                } label: {
                    CurrentSelection.about.label
                }
            }

            SchedulePlaceholder()
        }
    }
}

private struct SchedulePlaceholder: View {
    var body: some View {
        Text("screen.schedule.placeholder.title")
    }
}
