import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    let items: [WhatsNewScreen.Item]
    var onAppear: () -> Void = {}

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(items, id: \.title) { item in
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

                Button(action: { dismiss() }) {
                    Text("Отстань")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
            }
            .tint(.red)
            .onAppear(perform: onAppear)
            .navigationTitle("Что нового")
        }
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(items: WhatsNewScreen.log.sorted(by: { $0.0 > $1.0 }).flatMap { $0.1 })
    }
}
