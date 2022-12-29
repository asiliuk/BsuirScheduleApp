import SwiftUI
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PairFormsColorPickerView: View {
    let store: StoreOf<PairFormsColorPicker>

    public var body: some View {
        WithViewStore(store, observe: \.hasChanges) { viewStore in
            Section(header: Text("screen.settings.appearance.colors.section.header")) {
                ForEachStore(
                    store.scope(state: \.pairFormColorPickers, reducerAction: { .pairFormColorPickers(id: $0, action: $1) }),
                    content: PairFormColorPickerView.init(store:)
                )

                if viewStore.state {
                    Button("screen.settings.appearance.colors.reset.title") {
                        viewStore.send(.resetButtonTapped, animation: .default)
                    }
                }
            }
        }
    }
}

private struct PairFormColorPickerView: View {
    let store: StoreOf<PairFormColorPicker>

    var body: some View {
        WithViewStore(store) { viewStore in
            Picker(viewStore.name, selection: viewStore.binding(\.$color)) {
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
