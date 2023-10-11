import SwiftUI
import BsuirUI

struct GroupsPlaceholderView: View {
    private let hasPinned: Bool
    private let numberOfFavorites: Int

    init(hasPinned: Bool, numberOfFavorites: Int) {
        self.hasPinned = hasPinned
        self.numberOfFavorites = numberOfFavorites
    }

    var body: some View {
        List {
            if hasPinned {
                groupsSection(title: "screen.groups.pinned.section.header", numberOfRows: 1)
            }

            if numberOfFavorites > 0 {
                groupsSection(title: "screen.groups.favorites.section.header", numberOfRows: numberOfFavorites)
            }

            groupsSection(title: "------", numberOfRows: 6)
            groupsSection(title: "------", numberOfRows: 2)
            groupsSection(title: "------", numberOfRows: 1)
            groupsSection(title: "------", numberOfRows: 8)
        }
        .listStyle(.insetGrouped)
        .allowsHitTesting(false)
    }

    func groupsSection(title: LocalizedStringKey, numberOfRows: Int) -> some View {
        Section {
            ForEach(0..<numberOfRows, id: \.self) { _ in
                groupRowPlaceholder
            }
        } header: {
            Text(title)
                .shimmeringPlaceholder()
        }
    }

    var groupRowPlaceholder: some View {
        Text(placeholderText(length: 12))
            .shimmeringPlaceholder()
    }
}

#Preview {
    GroupsPlaceholderView(hasPinned: true, numberOfFavorites: 3)
}
