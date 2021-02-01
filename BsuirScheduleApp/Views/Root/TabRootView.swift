import SwiftUI

struct TabRootView: View {
    let state: AppState
    @Binding var currentSelection: CurrentSelection?

    var body: some View {
        TabView(selection: $currentSelection.tab) {
            NavigationView {
                AllFavoritesView(screen: state.allFavorites, selection: currentSelection?.favoriteSelection)
            }
            .tab(.favorites())

            NavigationView {
                AllGroupsView(screen: state.allGroups, selectedGroup: $currentSelection.selectedGroup)
            }
            .tab(.groups())

            NavigationView {
                AllLecturersView(screen: state.allLecturers, selectedLecturer: $currentSelection.selectedLecturer)
            }
            .tab(.lecturers())

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

    var selectedGroup: Int? {
        get { self?.selectedGroup }
        set { self?.selectedGroup = newValue }
    }

    var selectedLecturer: Int? {
        get { self?.selectedLecturer }
        set { self?.selectedLecturer = newValue }
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
            case .groups: self = .groups()
            case .lecturers: self = .lecturers()
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

extension CurrentSelection {
    var selectedGroup: Int? {
        get {
            switch self {
            case let .groups(id):
                return id
            case .about, .favorites, .lecturers:
                return nil
            }
        }
        set {
            self = .groups(id: newValue)
        }
    }

    var selectedLecturer: Int? {
        get {
            switch self {
            case let .lecturers(id):
                return id
            case .about, .favorites, .groups:
                return nil
            }
        }
        set {
            self = .lecturers(id: newValue)
        }
    }
}
