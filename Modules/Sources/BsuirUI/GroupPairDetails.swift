import SwiftUI

public struct GroupPairDetails: View {
    let groups: [String]
    @ScaledMetric(relativeTo: .body) private var overlap: CGFloat = 10
    private let maxGroupsToShow = 2

    public init(groups: [String]) {
        self.groups = groups
    }

    public var body: some View {
        if !groups.isEmpty {
            HStack(spacing: -overlap) {
                ForEach(groups.prefix(maxGroupsToShow), id: \.self) { group in
                    GroupAvatar(group: group)
                }

                if groups.count > maxGroupsToShow {
                    Text("+")
                        .foregroundColor(.primary)
                        .font(.headline.monospacedDigit())
                        .padding(2)
                        .modifier(GroupBackgroud())
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

private struct GroupAvatar: View {
    let group: String

    var body: some View {
        Text(group.splitting(after: 3))
            .foregroundColor(.primary)
            .font(.headline.monospacedDigit())
            .lineSpacing(-1)
            .padding(.vertical, -2)
            .padding(6)
            .modifier(GroupBackgroud())
    }
}

private struct GroupBackgroud: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                Circle()
                    .stroke()
                    .background {
                        Circle()
                            .foregroundColor(Color(uiColor: .secondarySystemGroupedBackground))
                    }
                    .scaledToFill()
                    .foregroundColor(.primary.opacity(0.1))
            }
    }
}

private extension String {
    func splitting(after charCount: Int) -> String {
        guard let index = self.index(startIndex, offsetBy: charCount, limitedBy: endIndex) else {
            return self
        }

        var copy = self
        copy.insert("\n", at: index)
        return copy
    }
}

#if DEBUG
struct GroupPairDetails_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GroupPairDetails(groups: ["101001", "101002"])
            
            GroupPairDetails(groups: ["020605", "020604", "020603", "020602", "020601"])

            GroupPairDetails(groups: ["101001", "101002"])
                .environment(\.sizeCategory, .extraExtraLarge)
                .environment(\.colorScheme, .dark)
            
            GroupPairDetails(groups: ["020605", "020604", "020603", "020602", "020601"])
                .environment(\.sizeCategory, .extraExtraLarge)
                .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
        .padding(4)
        .background(Color(uiColor: .secondarySystemBackground))
    }
}
#endif
