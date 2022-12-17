import SwiftUI
import BsuirUI

struct LecturersPlaceholderView: View {
    private let favoriteOffsets: [Int]
    private let lecturersOffsets: [Int]

    init(numberOfFavorites: Int) {
        favoriteOffsets = (0..<numberOfFavorites).map { _ in Int.random(in: 0...4) }
        lecturersOffsets = (0..<20).map { _ in Int.random(in: 0...5) }
    }

    var body: some View {
        PlaceholderView(speed: 0.07) { iteration in
            List {
                Section("screen.lecturers.favorites.section.header") {
                    ForEach(favoriteOffsets.indices, id: \.self) { idx in
                        let offset = favoriteOffsets[idx]
                        LecturerCellView(fullName: placeholderText(for: iteration, from: 5 + offset, to: 25 + offset), imageUrl: nil)
                    }
                }

                Section {
                    ForEach(lecturersOffsets.indices, id: \.self) { idx in
                        let offset = lecturersOffsets[idx]
                        LecturerCellView(fullName: placeholderText(for: iteration, from: 5 + offset, to: 25 + offset), imageUrl: nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .allowsHitTesting(false)
        }
    }
}
