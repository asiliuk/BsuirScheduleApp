import SwiftUI
import AboutFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public enum CurrentSelection: Hashable {
    case pinned
    case groups
    case lecturers
    case about
}

public enum CurrentOverlay: Identifiable {
    public var id: Self { self }
    case about
}

public struct AppView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        content
            .onOpenURL(perform: { ViewStore(store.stateless).send(.handleDeeplink($0)) })
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

extension Label where Title == Text, Icon == Image {
    static func pinned(title: String) -> Label { Label(title, systemImage: "pin") }
    static let groups = Label("view.tabBar.groups.title", systemImage: "person.2")
    static let lecturers = Label("view.tabBar.lecturers.title", systemImage: "person.text.rectangle")
    static let about = Label("view.tabBar.about.title", systemImage: "info.circle")
}
