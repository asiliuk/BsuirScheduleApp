//
//  NavigationLink+Extensions.swift
//  BsuirUI
//
//  Created by Anton Siliuk on 26.09.21.
//  Copyright © 2021 Saute. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    public func navigation<Item: Identifiable, Destination: View>(
        item: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        background(DynamicNavigationLink(item: item, destination: destination))
    }
}

struct DynamicNavigationLink<Item: Identifiable, Destination: View>: View {
    @Binding var item: Item?
    @ViewBuilder var destination: (Item) -> Destination

    var body: some View {
        NavigationLink(
            destination: item.map(destination),
            isActive: Binding(
                get: { item != nil },
                set: { value in
                    if !value {
                        item = nil
                    }
                }
            ),
            label: EmptyView.init
        )
    }
}


struct Navigation_Previews: PreviewProvider {
    struct TestView: View {
        enum Content: Hashable, Identifiable {
            var id: Self { self }

            case first
            case second
        }

        @State var content: Content?

        var body: some View {
            VStack {
                Button { content = .first } label: { Text("first") }
                Button { content = .second } label: { Text("second") }
            }
            .navigation(item: $content) { content in
                switch content {
                case .first:
                    Text("First content")
                case .second:
                    Text("Second content")
                }
            }
        }
    }

    static var previews: some View {
        NavigationView {
            TestView()
        }
    }
}
