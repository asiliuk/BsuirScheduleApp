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
    
    var body: some View {
        HStack() {

            VStack(alignment: .trailing) {
                Text("20:25").font(.callout)
                Text("22:00").font(.footnote)
            }
            
            Rectangle().frame(width: 2).foregroundColor(.red)
            
            VStack(alignment: .leading) {
                Text("ОТ").font(.headline).bold()
                Text("601-2").font(.callout)
            }
            
            Spacer()
            
            image
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(image: Image("barkova"))
            .environment(\.colorScheme, .dark)
            .environment(\.sizeCategory, .extraLarge)
    }
}
#endif
