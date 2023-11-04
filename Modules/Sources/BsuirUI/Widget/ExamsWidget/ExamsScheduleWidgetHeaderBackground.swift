import SwiftUI

struct ExamsScheduleWidgetHeaderBackground: View {
    @EnvironmentObject private var pairFormDisplayService: PairFormDisplayService

    var body: some View {
        pairFormDisplayService.color(for: .exam).color
            .overlay {
                VStack {
                    ForEach(0..<10) { row in
                        HStack {
                            ForEach(0..<20) { _ in
                                Image(systemName: "graduationcap")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.secondary.opacity(0.4))
                                    .blendMode(.hardLight)
                            }
                        }
                        .offset(x: row.isMultiple(of: 2) ? -15 : 0)
                    }
                }
                .rotationEffect(.degrees(-15))
            }
            .clipped()
    }
}
