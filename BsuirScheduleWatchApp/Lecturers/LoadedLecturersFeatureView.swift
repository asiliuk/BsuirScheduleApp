import SwiftUI
import BsuirApi
import ComposableArchitecture
import BsuirUI

struct LoadedLecturersFeatureView: View {
    let store: StoreOf<LoadedLecturersFeature>
    let refresh: () async -> Void

    var body: some View {
        List {
            ForEach(store.lecturers) { lecturer in
                Button {
                    store.send(.rowTapped(lecturer))
                } label: {
                    HStack {
                        Avatar(
                            url: lecturer.actualPhotoLink,
                            baseSize: 32
                        )
                        Text(verbatim: lecturer.compactFio)
                    }
                }
            }
        }
        .refreshable { await refresh() }
    }
}
