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
                            for: PinnedScheduleWidgetSmallView(config: .preview, date: .now),
                            ofSize: CGSize(width: 170, height: 170),
                            targetSize: CGSize(width: widgetPreviewSize / 2, height: widgetPreviewSize / 2)
                        )
                        widgetPreview(
                            for: PinnedScheduleWidgetSmallView(config: .preview, date: .now),
                            ofSize: CGSize(width: 170, height: 170),
                            targetSize: CGSize(width: widgetPreviewSize / 2, height: widgetPreviewSize / 2)
                        )
                    }

                    widgetPreview(
                        for: PinnedScheduleWidgetMediumView(config: .preview, date: .now),
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

    private func widgetPreview(for widget: some View, ofSize size: CGSize, targetSize: CGSize) -> some View {
        let scale = targetSize.height / size.height
        return widget
            .padding()
            .frame(width: size.width, height: size.height)
            .background {
                RoundedRectangle(cornerRadius: size.height * 0.11, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            }
            .scaleEffect(x: scale, y: scale)
            .frame(width: targetSize.width, height: targetSize.height)
    }
}
