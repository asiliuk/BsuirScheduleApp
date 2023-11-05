import SwiftUI

struct ExamsScheduleWidgetHeaderBackground: View {
    @EnvironmentObject private var pairFormDisplayService: PairFormDisplayService
    var shouldFillWithExamColor: Bool = true

    var body: some View {
        fillColor
            .overlay {
                VStack {
                    ForEach(0..<10) { row in
                        HStack {
                            ForEach(0..<20) { _ in
                                Image(systemName: "graduationcap")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(foregroundColor)
                                    .blendMode(.hardLight)
                            }
                        }
                        .offset(x: row.isMultiple(of: 2) ? -15 : 0)
                    }
                }
                .rotationEffect(.degrees(-15))
            }
            .clipped()
            .contentTransition(.identity)
    }

    private var fillColor: Color {
        shouldFillWithExamColor ? examColor : .clear
    }

    private var foregroundColor: Color {
        shouldFillWithExamColor
            ? Color.secondary.opacity(0.4)
            : examColor.opacity(0.4)
    }

    private var examColor: Color {
        pairFormDisplayService.color(for: .exam).color
    }
}
