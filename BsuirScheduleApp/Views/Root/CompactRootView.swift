import SwiftUI
import BsuirCore
import AboutFeature
import GroupsFeature

struct CompactRootView: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?

    var body: some View {
        TabView(selection: $currentSelection) {
            NavigationView {
                AllFavoritesView(screen: state.allFavorites, openGroups: { currentSelection = .groups })
            }
            .tab(.favorites)

            NavigationView {
                AllGroupsView(screen: state.allGroups)
            }
            .tab(.legacyGroups)
            
            NavigationView {
                GroupsView(store: state.groupsStore)
            }
            .tab(.groups)

            NavigationView {
                AllLecturersView(screen: state.allLecturers)
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
