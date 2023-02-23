import SwiftUI
import BsuirUI
import Collections

struct PremiumAppIconGrid: View {
    private let gridRows: [[AppIcon]]
    @State private var isAnimating = false
    private let animationSpeed: CGFloat = 0.01

    init() {
        let premiumIcons = AppIcon.allCases.filter(\.isPremium)
        // Show 3 rows of icons
        self.gridRows = (0..<3).map { _ in
            let icons = premiumIcons.shuffled()
            // Repeat first 3 icons so animation will look continious
            return icons + Array(icons.prefix(3))
        }
    }

    var body: some View {
        AppIconsGrid(
            gridRows: gridRows,
            isAtTheBegining: isAnimating
        )
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(.linear.speed(animationSpeed).repeatForever(autoreverses: false)) {
                isAnimating.toggle()
            }
        }
        .mask { SlightlyBluredEdgesMask() }
    }
}

private struct AppIconsGrid: View {
    let gridRows: [[AppIcon]]
    let isAtTheBegining: Bool

    let spacing: CGFloat = 3
    let numberOfItemsVisibleAtOnce = 2

    private var numberOfRows: Int { gridRows.count }
    private var numberOfItemsInTheRow: Int { gridRows.first?.count ?? 0 }

    var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: numberOfItemsInTheRow), spacing: spacing) {
                ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                    ForEach(0..<numberOfItemsInTheRow, id: \.self) { itemIndex in
                        GeometryReader { itemProxy in
                            AppIconPreviewView(
                                imageName: gridRows[rowIndex][itemIndex].previewImageName,
                                size: itemProxy.size.width
                            )
                            .offset(x: rowIndex.isMultiple(of: 2) ? 0 : -itemProxy.size.width / 2)
                        }
                        .aspectRatio(1, contentMode: .fill)
                        .padding(spacing / 2)
                        .id(rowIndex * numberOfItemsInTheRow + itemIndex)
                    }
                }
            }
            .offset(
                x: isAtTheBegining ? -proxy.size.width * (percentItemsVisible - 1.5) : 0,
                y: -proxy.size.height / (CGFloat(numberOfItemsVisibleAtOnce) * 1.15)
            )
            .rotationEffect(.degrees(-8))
            .frame(width: proxy.size.width * percentItemsVisible, alignment: .trailing)
        }
    }

    private var percentItemsVisible: CGFloat {
        CGFloat(numberOfItemsInTheRow) / CGFloat(numberOfItemsVisibleAtOnce)
    }
}

private struct SlightlyBluredEdgesMask: View {
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: proxy.size.width * 0.15)
                .fill()
                .padding(2)
                .blur(radius: 2)
        }
    }
}

struct PremiumAppIconGrid_Previews: PreviewProvider {
    static var previews: some View {
        PremiumAppIconGrid()
            .frame(width: 100)
            .previewLayout(.sizeThatFits)
    }
}
