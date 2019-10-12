//
//  ContentView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 8/5/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let image: Image
    var body: some View {
        List {
            ForEach(0..<10) { _ in
                PairCell(image: self.image)
            }
        }
    }
}

struct PairCell: View {
    
    let image: Image
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        HStack() {

            if sizeCategory.isAccessibility {

                Rectangle().frame(width: 5).foregroundColor(.red)

                VStack(alignment: .leading) {
                    
                    Text("20:25-22:00").font(.callout)

                    HStack() {
                        Text("ОТ").font(.headline).bold()
                        Text("601-2").font(.caption)
                    }
                }
            } else {

                VStack(alignment: .trailing) {
                    Text("20:25").font(.callout)
                    Text("22:00").font(.footnote)
                }

                Rectangle().frame(width: 2).foregroundColor(.red)

                VStack(alignment: .leading) {
                    Text("ОТ").font(.headline).bold()
                    Text("601-2").font(.callout)
                }
            }
            
            Spacer().layoutPriority(-1)

            image
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
}

extension ContentSizeCategory {

    var isAccessibility: Bool {
        switch self {
        case .accessibilityLarge,
             .accessibilityMedium,
             .accessibilityExtraLarge,
             .accessibilityExtraExtraLarge,
             .accessibilityExtraExtraExtraLarge:
            return true
        default:
            return false
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static let image = Image("barkova")
    static var previews: some View {
        Group {
            PairCell(image: image)
                .environment(\.colorScheme, .dark)
                .background(Color.black)

            PairCell(image: image)
                .environment(\.sizeCategory, .accessibilityMedium)
                .previewLayout(.fixed(width: 320, height: 100))

            PairCell(image: image)
        }
        .previewLayout(.fixed(width: 320, height: 60))
    }
}
#endif
