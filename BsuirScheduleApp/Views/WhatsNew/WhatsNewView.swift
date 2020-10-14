import SwiftUI

struct WhatsNewView: View {
    @Environment(\.presentationMode) var presentationMode
    let items: [WhatsNewScreen.Item]
    var onAppear: () -> Void = {}

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(items.indices, id: \.self) {
                        let item = items[$0]
                        HStack {
                            Image(systemName: item.imageName)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.red)
                                .frame(width: 50, height: 50)
                                .padding(.horizontal)

                            VStack(alignment: .leading) {
                                Text(item.title).font(.headline).bold()
                                Text(item.description).font(.footnote)
                            }

                            Spacer()
                        }
                        .padding()
                    }
                    .frame(maxWidth: 600)
                }

                Spacer()

                Button("Отстань") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(FillButtonStyle(backgroundColor: .red))
                .padding()
            }
            .onAppear(perform: onAppear)
            .navigationTitle("Что нового")
        }
    }
}

struct FillButtonStyle: ButtonStyle {
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Color(.systemBackground))
            .padding()
            .frame(minWidth: 0, maxWidth: 400)
            .background(backgroundColor)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(items: WhatsNewScreen.log.sorted(by: { $0.0 > $1.0 }).flatMap { $0.1 })
    }
}
