import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

#if DEBUG
public struct MyFeature: ReducerProtocol {
    public struct State: Equatable {
        @LoadableState var groups: [String]?
        @LoadableState var myself: LecturerFeature.State?
        @LoadableState var lecturers: LecturersFeature.State?
        
        public init() {}
    }
    
    public enum Action: LoadableAction {
        case lecturers(LecturersFeature.Action)
        case myself(LecturerFeature.Action)
        case loading(LoadingAction<State>)
    }
    
    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .loading(.finished(\.$groups)):
                print("$groups did load")
                return .none
                
            case .loading(.finished(\.$lecturers)):
                print("$lecturers did load")
                return .none
                
            case .loading(.finished(\.$myself)):
                print("$myself did load")
                return .none
            default:
                return .none
            }
        }
        .load(\.$groups) { state in
                .task {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    return .success(["1", "2", "3"])
                }
        }
        .load(\.$lecturers, action: /Action.lecturers) {
            LecturersFeature()
                ._printChanges()
        } fetch: { _ in
            return .task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                let start = Int.random(in: 0..<3)
                let end = Int.random(in: 5..<9)
                let lecturers = (start...end).map { index in
                    LecturerFeature.State(name: "Lect Anton Siliuk \(index)")
                }
                
                return .success(IdentifiedArray(uniqueElements: lecturers))
            }
        }
        .load(\.$myself, action: /Action.myself) {
            LecturerFeature()
        } fetch: { _ in
                .task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    return .success(.init(name: "Anton Siliuk"))
                }
        }
    }
}

public struct LecturersFeature: ReducerProtocol {
    public typealias State = IdentifiedArrayOf<LecturerFeature.State>
    
    public enum Action {
        case lecturer(id: String, action: LecturerFeature.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
            .forEach(\.self, action: /Action.lecturer) {
                LecturerFeature()
            }
    }
}

public struct LecturerFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: String { name }
        let name: String
        var isFavorite: Bool = false
    }
    
    public enum Action {
        case toggleFavorite
    }
    
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .toggleFavorite:
            state.isFavorite.toggle()
            return .none
        }
    }
}

import SwiftUI

public struct MyFeatureView: View {
    public let store: StoreOf<MyFeature>
    
    public init(store: StoreOf<MyFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section("Groups") {
                    LoadingStore(store, state: \.$groups) { store in
                        WithViewStore(store) { viewStore in
                            ForEach(viewStore.state, id: \.self) { value in
                                Text(value)
                            }
                        }
                    } loading: {
                        ProgressView().frame(maxWidth: .infinity)
                    } error: { _ in
                        Color.red
                    }
                }
                
                Section("Myself") {
                    LoadingStore(store, state: \.$myself, action: MyFeature.Action.myself) { store in
                        LecturerView(store: store.loaded())
                    } loading: {
                        ProgressView().frame(maxWidth: .infinity)
                    } error: { _ in
                        Color.red
                    }
                }
                
                Section("Lecturers") {
                    LoadingStore(store, state: \.$lecturers, action: MyFeature.Action.lecturers) { store in
                        ForEachStore(store.loaded().scope(
                            state: { $0 },
                            action: LecturersFeature.Action.lecturer
                        )) { lecturerStore in
                            LecturerView(store: lecturerStore)
                        }
                    } loading: {
                        ProgressView().frame(maxWidth: .infinity)
                    } error: { _ in
                        Color.red
                    }
                }
            }
            .refreshable {
                await viewStore.send(.loading(.refresh(\.$lecturers))).finish()
            }
        }
    }
}

private struct LecturerView: View {
    let store: StoreOf<LecturerFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Text(viewStore.name)
                Spacer()
                Button {
                    viewStore.send(.toggleFavorite)
                } label: {
                    Image(systemName: viewStore.isFavorite ? "star.fill" : "star")
                }
                .tint(.yellow)
            }
        }
    }
}
#endif
