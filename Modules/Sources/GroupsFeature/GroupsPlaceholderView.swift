import SwiftUI
import BsuirUI

struct GroupsPlaceholderView: View {
    private let hasPinned: Bool
    private let favoriteOffsets: [Int]

    init(hasPinned: Bool, numberOfFavorites: Int) {
        self.hasPinned = hasPinned
        favoriteOffsets = (0..<numberOfFavorites).map { _ in Int.random(in: 0..<4) }
    }

    var body: some View {
        PlaceholderView(speed: 0.07) { iteration in
            List {
                if hasPinned {
                    Section("screen.groups.pinned.section.header") {
                        Text(placeholderText(for: iteration, from: 4, to: 18))
                    }
                }

                if !favoriteOffsets.isEmpty {
                    Section("screen.groups.favorites.section.header") {
                        ForEach(favoriteOffsets.indices, id: \.self) { idx in
                            let offset = favoriteOffsets[idx]
                            Text(placeholderText(for: iteration, from: 4 + offset, to: 18 + offset))
                        }
                    }
                }

                Section("---") {
                    Text(placeholderText(for: iteration, from: 4, to: 18))
                    Text(placeholderText(for: iteration, from: 5, to: 19))
                    Text(placeholderText(for: iteration, from: 1, to: 15))
                    Text(placeholderText(for: iteration, from: 4, to: 18))
                    Text(placeholderText(for: iteration, from: 5, to: 19))
                    Text(placeholderText(for: iteration, from: 1, to: 15))
                }

                Section("---") {
                    Text(placeholderText(for: iteration, from: 4, to: 18))
                    Text(placeholderText(for: iteration, from: 5, to: 19))
                }

                Section("---") {
                    Text(placeholderText(for: iteration, from: 4, to: 18))
                }

                Section("---") {
                    Text(placeholderText(for: iteration, from: 4, to: 18))
                    Text(placeholderText(for: iteration, from: 5, to: 19))
                    Text(placeholderText(for: iteration, from: 1, to: 15))
                    Text(placeholderText(for: iteration, from: 4, to: 18))
                    Text(placeholderText(for: iteration, from: 5, to: 19))
                    Text(placeholderText(for: iteration, from: 1, to: 15))
                    Text(placeholderText(for: iteration, from: 4, to: 18))
                    Text(placeholderText(for: iteration, from: 5, to: 19))
                }
            }
            .listStyle(.insetGrouped)
            .allowsHitTesting(false)
        }
    }
}
