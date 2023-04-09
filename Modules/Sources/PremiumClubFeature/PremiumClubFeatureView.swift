import SwiftUI
import BsuirUI
import ComposableArchitecture

public struct PremiumClubFeatureView: View {
    let store: StoreOf<PremiumClubFeature>

    public init(store: StoreOf<PremiumClubFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
#if DEBUG
                VStack(alignment: .leading) {
                    DebugPremiumClubRowView(
                        store: store.scope(
                            state: \.debugRow,
                            action: PremiumClubFeature.Action.debugRow
                        )
                    )

                    WithViewStore(store, observe: \.source) { viewStore in
                        let source = Text("\(viewStore.state.map(String.init(describing:)) ?? "No source")").bold()
                        Text("Source: \(source)")
                    }
                }
#endif

                WithViewStore(store, observe: \.sections) { viewStore in
                    ForEach(viewStore.state) { section in
                        switch section {
                        case .fakeAds:
                            FakeAdsSection()
                        case .pinnedSchedule:
                            PinnedScheduleSection()
                        case .widgets:
                            WidgetsSection()
                        case .appIcons:
                            AppIconsSection()
                        case .tips:
                            TipsSection()
                        }
                    }
                }
            }
            .padding()
        }
        .labelStyle(PremiumGroupTitleLabelStyle())
        .safeAreaInset(edge: .bottom) {
                Button {} label: { Text("Buy premium pass").frame(maxWidth: .infinity) }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .padding()
                    .background(.thickMaterial)
        }
        .navigationTitle("Premium Club")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Restore") {}
            }
        }
    }
}

private struct AppIconsSection: View {
    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                Text("Unlock stunning new icons, I've spent a lot of time designing them, more to come...").font(.body)
                Spacer()
                PremiumAppIconGrid()
                    .frame(width: 80)
            }
        } label: {
            Label("Custom App Icons", systemImage: "app.gift.fill")
                .settingsRowAccent(.orange)
        }
    }
}

private struct PinnedScheduleSection: View {
    var body: some View {
        GroupBox {
            Color.clear
                .frame(height: 100)
        } label: {
            Label("Pinned Schedule", systemImage: "pin.square.fill")
                .settingsRowAccent(.red)
        }
    }
}

private struct WidgetsSection: View {
    let widgetPreviewSize: Double = 80

    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                Text("Checked your pinned schedule right at the home or lock screen").font(.body)
                Spacer()
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        widgetPreview(
                            for: ScheduleWidgetEntrySmallView(config: .preview, date: .now),
                            ofSize: CGSize(width: 170, height: 170),
                            targetSize: CGSize(width: widgetPreviewSize / 2, height: widgetPreviewSize / 2)
                        )
                        widgetPreview(
                            for: ScheduleWidgetEntrySmallView(config: .preview, date: .now),
                            ofSize: CGSize(width: 170, height: 170),
                            targetSize: CGSize(width: widgetPreviewSize / 2, height: widgetPreviewSize / 2)
                        )
                    }

                    widgetPreview(
                        for: ScheduleWidgetEntryMediumView(config: .preview, date: .now),
                        ofSize: CGSize(width: 364, height: 170),
                        targetSize: CGSize(width: widgetPreviewSize, height: widgetPreviewSize / 2)
                    )
                }
                .redacted(reason: .placeholder)
                .frame(width: widgetPreviewSize, height: widgetPreviewSize)
            }
        } label: {
            Label("Widgets", systemImage: "square.text.square.fill")
                .settingsRowAccent(.blue)
        }
    }

    private func widgetPreview(for widget: some View, ofSize size: CGSize, targetSize: CGSize) -> some View {
        let scale = targetSize.height / size.height
        return widget
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: size.height * 0.11, style: .continuous))
            .scaleEffect(x: scale, y: scale)
            .frame(width: targetSize.width, height: targetSize.height)
    }
}

private struct FakeAdsSection: View {
    var body: some View {
        GroupBox {
            Color.clear
                .frame(height: 100)
        } label: {
            Label("No Fake Ads", systemImage: "hand.raised.square.fill")
                .settingsRowAccent(.purple)
        }
    }
}

private struct TipsSection: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                LabeledContent {
                    Button("1.99$", action: {})
                } label: {
                    Text("☕️ Small tip")
                }

                LabeledContent {
                    Button("5.00$", action: {})
                } label: {
                    Text("🥐 Medium tip")
                }

                LabeledContent {
                    Button("10.00$", action: {})
                } label: {
                    Text("🥙 Big tip")
                }

                Text("* Any tips amount removes fake ads banner")
                    .font(.footnote)
            }
            .buttonStyle(.borderedProminent)
        } label: {
            Label("Leave tips", systemImage: "heart.square.fill")
                .settingsRowAccent(.pink)
        }
    }
}

private struct PremiumGroupTitleLabelStyle: LabelStyle {
    @Environment(\.settingsRowAccent) var settingsRowAccent

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            if let settingsRowAccent {
                configuration.icon
                    .font(.title2.bold())
                    .foregroundStyle(settingsRowAccent)
            }
        }
    }
}

struct PremiumClubFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PremiumClubFeatureView(
                store: .init(
                    initialState: .init(),
                    reducer: PremiumClubFeature()
                )
            )
        }
    }
}
