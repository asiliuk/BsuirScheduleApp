import SwiftUI
import AboutFeature
import ComposableArchitecture
import ComposableArchitectureUtils

enum CurrentSelection: Hashable {
    case groups
    case lecturers
    case about
}

enum CurrentOverlay: Identifiable {
    var id: Self { self }
    case about
}

struct RootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let store: StoreOf<AppFeature>

    var body: some View {
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

extension CurrentSelection {
    @ViewBuilder var label: some View {
        switch self {
        case .groups:
            Label("view.tabBar.groups.title", systemImage: "person.2")
        case .lecturers:
            Label("view.tabBar.lecturers.title", systemImage: "person.text.rectangle")
        case .about:
            Label("view.tabBar.about.title", systemImage: "info.circle")
        }
    }
}
