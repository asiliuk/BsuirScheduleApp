import SwiftUI
import BsuirUI

struct WidgetsSectionView: View {
    let widgetPreviewSize: Double = 80

    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                Text("screen.premiumClub.section.widgets.message").font(.body)
                Spacer()
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        widgetPreview(
                            for: PinnedScheduleWidgetSmallView(config: .preview),
                            ofSize: CGSize(width: 170, height: 170),
                            targetSize: CGSize(width: widgetPreviewSize / 2, height: widgetPreviewSize / 2)
                        )
                        widgetPreview(
                            for: ExamsScheduleWidgetSmallView(config: .preview(onlyExams: false)),
                            ofSize: CGSize(width: 170, height: 170),
                            targetSize: CGSize(width: widgetPreviewSize / 2, height: widgetPreviewSize / 2),
                            addPadding: false
                        )
                    }

                    widgetPreview(
                        for: PinnedScheduleWidgetMediumView(config: .preview),
                        ofSize: CGSize(width: 364, height: 170),
                        targetSize: CGSize(width: widgetPreviewSize, height: widgetPreviewSize / 2)
                    )
                }
                .redacted(reason: .placeholder)
                .frame(width: widgetPreviewSize, height: widgetPreviewSize)
            }
        } label: {
            Label("screen.premiumClub.section.widgets.title", systemImage: "square.text.square.fill")
                .settingsRowAccent(.blue)
        }
    }

    @ViewBuilder
    private func widgetPreview(
        for widget: some View,
        ofSize size: CGSize,
        targetSize: CGSize,
        addPadding: Bool = true
    ) -> some View {
        let scale = targetSize.height / size.height
        let backgroundShape = RoundedRectangle(cornerRadius: size.height * 0.11, style: .continuous)
        Group {
            if addPadding {
                widget.padding()
            } else {
                widget
            }
        }
        .frame(width: size.width, height: size.height)
        .background { backgroundShape.fill(Color(uiColor: .systemBackground)) }
        .clipShape(backgroundShape)
        .scaleEffect(x: scale, y: scale)
        .frame(width: targetSize.width, height: targetSize.height)
    }
}
