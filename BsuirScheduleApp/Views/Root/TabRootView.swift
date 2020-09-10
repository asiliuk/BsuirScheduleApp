import SwiftUI

struct TabRootView: View {
    let state: AppState
    @Binding var currentTab: CurrentTab?

    var body: some View {
        TabView(selection: $currentTab) {
            NavigationView { AllFavoritesView(screen: state.allFavorites, selection: currentTab?.favoriteSelection) }.tab(.favorites())
            NavigationView { AllGroupsView(screen: state.allGroups) }.tab(.groups)
            NavigationView { AllLecturersView(screen: state.allLecturers) }.tab(.lecturers)
            NavigationView { AboutView() }.tab(.about)
        }
    }
}

private extension View {
    func tab(_ tab: CurrentTab?) -> some View {
        self
            .tabItem { tab?.label }
            .tag(tab)
    }
}

private extension CurrentTab {
    var favoriteSelection: AllFavoritesView.Selection? {
        switch self {
        case let .favorites(selection):
            return selection
        case .about, .groups, .lecturers:
            return nil
        }
    }
}
