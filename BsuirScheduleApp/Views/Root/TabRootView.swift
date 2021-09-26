import SwiftUI

struct TabRootView: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?

    var body: some View {
        TabView(selection: $currentSelection.tab) {
            NavigationView {
                AllFavoritesView(screen: state.allFavorites, selection: currentSelection?.favoriteSelection, openGroups: { currentSelection = .groups })
            }
            .tab(.favorites())

            NavigationView {
                AllGroupsView(screen: state.allGroups)
            }
            .tab(.groups)

            NavigationView {
                AllLecturersView(screen: state.allLecturers)
            }
            .tab(.lecturers)

            NavigationView {
                AboutView(screen: state.about)
            }
            .tab(.about)
        }
    }
}

private extension TabRootView {
    enum Tab: Hashable {
        case groups
        case lecturers
        case favorites
        case about
    }
}

extension Optional where Wrapped == CurrentSelection {
    fileprivate var tab: TabRootView.Tab {
        get { self?.tab ?? .groups }
        set { self?.tab = newValue }
    }
}

private extension CurrentSelection {
    var tab: TabRootView.Tab {
        get {
            switch self {
            case .groups: return .groups
            case .lecturers: return .lecturers
            case .favorites: return .favorites
            case .about: return .about
            }
        }
        set {
            switch newValue {
            case .groups: self = .groups
            case .lecturers: self = .lecturers
            case .favorites: self = .favorites()
            case .about: self = .about
            }
        }
    }
}

private extension View {
    func tab(_ selection: CurrentSelection) -> some View {
        self
            .tabItem { selection.label }
            .tag(selection.tab)
    }
}

private extension CurrentSelection {
    var favoriteSelection: AllFavoritesView.Selection? {
        switch self {
        case let .favorites(selection):
            return selection
        case .about, .groups, .lecturers:
            return nil
        }
    }
}
