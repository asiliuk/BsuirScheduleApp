import SwiftUI

public func combineTexts(_ texts: Text?..., separator: String = ", ") -> Text? {
    combineTexts(texts, separator: separator)
}

public func combineTexts(_ texts: some Sequence<Text?>, separator: String = ", ") -> Text? {
    let nonEmptyTexts = texts.compactMap { $0 }
    guard let first = nonEmptyTexts.first else { return nil }
    return nonEmptyTexts.dropFirst().reduce(first) { $0 + $1 }
}
