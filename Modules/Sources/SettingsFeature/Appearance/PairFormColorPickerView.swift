import SwiftUI
import BsuirUI
import ComposableArchitecture

public struct PairFormsColorPickerView: View {
    let store: StoreOf<PairFormsColorPicker>

    public var body: some View {
        Section(header: Text("screen.settings.appearance.colors.section.header")) {
            WithPerceptionTracking {
                ForEach(
                    store.scope(state: \.pairFormColorPickers, action: \.pairFormColorPickers),
                    content: PairFormColorPickerView.init(store:)
                )
                
                if store.hasChanges {
                    Button("screen.settings.appearance.colors.reset.title") {
                        store.send(.resetButtonTapped, animation: .default)
                    }
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}

private struct PairFormColorPickerView: View {
    @Perception.Bindable var store: StoreOf<PairFormColorPicker>

    var body: some View {
        WithPerceptionTracking {
            Picker(store.name, selection: $store.color) {
                ForEach(PairFormColor.allCases, id: \.self) { color in
                    ColorView(color: color.color, name: color.name)
                }
            }
        }
    }
}

private struct ColorView: View {
    let color: Color
    let name: LocalizedStringKey
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 24

    var body: some View {
        Label {
            Text(name)
        } icon: {
            Image(uiImage: iconImage)
        }
        .labelStyle(.iconOnly)
    }

    private var iconImage: UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { context in
            UIColor(color).setFill()
            UIBezierPath(roundedRect: context.format.bounds, cornerRadius: (8 / 34) * size).fill()
        }
    }
}
