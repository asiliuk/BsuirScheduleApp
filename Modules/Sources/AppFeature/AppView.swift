import SwiftUI
import SettingsFeature
import ComposableArchitecture

public enum CurrentSelection: Hashable {
    case pinned
    case groups
    case lecturers
    case settings
}

public struct AppView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        content
            .onOpenURL(perform: { store.send(.handleDeeplink($0)) })
    }

    @ViewBuilder private var content: some View {
        switch horizontalSizeClass {
        case nil, .compact?:
            CompactRootView(store: store)
        case .regular?:
            RegularRootView(store: store)
        case .some:
            EmptyView().onAppear { assertionFailure("Unexpected horizontalSizeClass") }
        }
    }
}

struct PinnedLabel: View {
    let title: String

    var body: some View {
        Label(title, systemImage: "pin")
    }
}

struct EmptyPinnedLabel: View {
    var body: some View {
        Label("view.tabBar.pinned.empty.title", systemImage: "pin")
            .environment(\.symbolVariants, .none)
    }
}

struct GroupsLabel: View {
    let body = Label("view.tabBar.groups.title", systemImage: "person.2")
}

struct LecturersLabel: View {
    let body = Label("view.tabBar.lecturers.title", systemImage: "person.text.rectangle")
}

struct SettingsLabel: View {
    let body = Label("view.tabBar.settings.title", systemImage: "gearshape")
}
