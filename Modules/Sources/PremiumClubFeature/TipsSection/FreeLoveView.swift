import SwiftUI
import ComposableArchitecture

struct FreeLoveView: View {
    let store: StoreOf<FreeLove>
    @State var buttonTappedCount: UInt = 0

    var body: some View {
        WithPerceptionTracking {
            LabeledContent {
                Button {
                    store.send(.loveButtonTapped)
                    buttonTappedCount += 1
                } label: {
                    HStack {
                        AnimatableFreeLoveText(counter: Double(store.counter))
                        if store.counter > 0 {
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
                    value: store.confettiCounter
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
                if store.highScore > 0 {
                    Text("screen.premiumClub.section.tips.freeLove.count\(String(store.highScore))")
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
