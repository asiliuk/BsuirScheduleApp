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
    public func navigation<V: Identifiable, Destination: View>(
        item: Binding<V?>,
        destination: @escaping (V) -> Destination
    ) -> some View {
        background(NavigationLink(item: item, destination: destination))
    }
}

extension NavigationLink where Label == EmptyView {
    public init?<V: Identifiable>(
        item: Binding<V?>,
        destination: @escaping (V) -> Destination
    ) {
        guard let value = item.wrappedValue else {
            return nil
        }

        self.init(
            destination: destination(value),
            isActive: .init(
                get: { item.wrappedValue != nil },
                set: { value in
                    // There's shouldn't be a way for SwiftUI to set `true` here.
                    if !value {
                        item.wrappedValue = nil
                    }
                }
            ),
            label: { EmptyView() }
        )
    }
}
