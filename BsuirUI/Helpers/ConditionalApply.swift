import SwiftUI

extension View {
    @ViewBuilder public func apply<Then: View, Else: View>(
        when condition: Bool,
        then makeThen: (Self) -> Then,
        else makeElse: (Self) -> Else
    ) -> some View {
        if condition {
            makeThen(self)
        } else {
            makeElse(self)
        }
    }

    public func apply<Then: View>(
        when condition: Bool,
        then makeThen: (Self) -> Then
    ) -> some View {
        apply(when: condition, then: makeThen, else: { $0 })
    }
}
