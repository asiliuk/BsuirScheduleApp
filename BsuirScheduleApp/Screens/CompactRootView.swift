import SwiftUI
import BsuirCore
import AboutFeature
import GroupsFeature
import LecturersFeature

struct CompactRootView: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?

    var body: some View {
        TabView(selection: $currentSelection) {            
            NavigationView {
                GroupsView(store: state.groupsStore)
            }
            .tab(.groups)
            
            NavigationView {
                LecturersView(store: state.lecturersStore)
            }
            .tab(.lecturers)

            NavigationView {
                AboutView(store: state.aboutStore)
            }
            .tab(.about)
        }
    }
}

extension View {
    func tab(_ selection: CurrentSelection) -> some View {
        self
            .tabItem { selection.label }
            .tag(Optional.some(selection))
    }
}
