import SwiftUI
import BsuirUI

struct LecturersPlaceholderView: View {
    private let hasPinned: Bool
    private let favoriteOffsets: [Int]
    private let lecturersOffsets: [Int]

    init(hasPinned: Bool, numberOfFavorites: Int) {
        self.hasPinned = hasPinned
        favoriteOffsets = (0..<numberOfFavorites).map { _ in Int.random(in: 0...4) }
        lecturersOffsets = (0..<20).map { _ in Int.random(in: 0...5) }
    }

    var body: some View {
        List {
            if hasPinned {
                lecturersSection(
                    title: "screen.lecturers.pinned.section.header",
                    nameLengthOffsets: [0]
                )
            }

            if !favoriteOffsets.isEmpty {
                lecturersSection(
                    title: "screen.lecturers.favorites.section.header",
                    nameLengthOffsets: favoriteOffsets
                )
            }

            lecturersSection(nameLengthOffsets: lecturersOffsets)
        }
        .listStyle(.insetGrouped)
        .allowsHitTesting(false)
    }

    func lecturersSection(title: LocalizedStringKey? = nil, nameLengthOffsets: [Int]) -> some View {
        Section {
            ForEach(nameLengthOffsets.indices, id: \.self) { idx in
                lecturerRowPlaceholder(nameLengthOffset: nameLengthOffsets[idx])
            }
        } header: {
            if let title {
                Text(title)
                    .shimmeringPlaceholder()
            }
        }
    }

    func lecturerRowPlaceholder(nameLengthOffset: Int = 0) -> some View {
        LecturerCellView(
            fullName: placeholderText(length: 15 + nameLengthOffset),
            imageUrl: nil
        )
        .shimmeringPlaceholder()
    }
}
