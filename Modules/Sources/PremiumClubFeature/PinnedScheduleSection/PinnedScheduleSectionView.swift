import SwiftUI
import BsuirUI

struct PinnedScheduleSectionView: View {
    var body: some View {
        GroupBox {
            HStack {
                Text("screen.premiumClub.section.pinned.message")
                Spacer()
                List {
                    ShimmeringScheduleSectionPlaceholder(
                        titleLength: 12,
                        numberOfPairs: 3
                    )
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color(uiColor: .tertiarySystemBackground))
                }
                .frame(width: 320, height: 500)
                .scaleEffect(x: 0.25, y: 0.25, anchor: .top)
                .frame(width: 80, height: 80, alignment: .top)
                .clipped()
                .rotationEffect(.degrees(-6), anchor: .top)
                .allowsHitTesting(false)
                .listStyle(.plain)
                .redacted(reason: .placeholder)
                .overlay(alignment: .top) {
                    Text("📌").font(.system(size: 24))
                        .alignmentGuide(HorizontalAlignment.center) { $0[.leading] }
                        .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                }
            }
        } label: {
            Label("screen.premiumClub.section.pinned.title", systemImage: "pin.square.fill")
                .settingsRowAccent(.red)
        }
    }
}
