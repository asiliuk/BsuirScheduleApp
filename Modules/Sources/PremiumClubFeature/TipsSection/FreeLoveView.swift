import SwiftUI
import ComposableArchitecture

struct FreeLoveView: View {
    let store: StoreOf<FreeLove>
    @State var buttonTappedCount: UInt = 0

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LabeledContent {
                Button {
                    viewStore.send(.loveButtonTapped)
                    buttonTappedCount += 1
                } label: {
                    HStack {
                        AnimatableFreeLoveText(counter: Double(viewStore.counter))
                        if viewStore.counter > 0 {
                            Text("\(Image(systemName: "heart.fill"))")
                        } else {
                            Text("\(Image(systemName: "heart"))")
                        }
                    }
                }
                .changeEffect(
                    .spray(origin: UnitPoint(x: 1, y: 0.5)) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    },
                    value: viewStore.confettiCounter
                )
                .changeEffect(
                    .rise(origin: UnitPoint(x: 1, y: 0.5)) {
                        Text("+\(Image(systemName: "heart.fill"))")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    },
                    value: buttonTappedCount
                )
            } label: {
                Text("screen.premiumClub.section.tips.freeLove.title")
                if viewStore.highScore > 0 {
                    Text("screen.premiumClub.section.tips.freeLove.count\(String(viewStore.highScore))")
                }
            }
        }
    }
}

private struct AnimatableFreeLoveText: View, Animatable {
    var counter: Double

    var animatableData: Double {
        get { counter }
        set { counter = newValue }
    }

    var body: some View {
        if counter > 0 {
            Text("\(Int(counter.rounded(.up)))").monospaced()
        }
    }
}
