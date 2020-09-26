import SwiftUI

func accessibilityDescription(_ tokens: LocalizedStringKey?..., separator: String = ", ") -> Text {
    combineTexts(tokens.map { $0.map { Text($0) } }) ?? Text("")
}

func combineTexts(_ texts: Text?..., separator: String = ", ") -> Text? {
    combineTexts(texts, separator: separator)
}

func combineTexts(_ texts: [Text?], separator: String = ", ") -> Text? {
    let notEmptyTexts = texts.compactMap { $0 }
    guard !notEmptyTexts.isEmpty else { return nil }

    let initialInterpolation = LocalizedStringKey.StringInterpolation(
        literalCapacity: notEmptyTexts.count * separator.count,
        interpolationCount: notEmptyTexts.count
    )

    let interpolation = notEmptyTexts.enumerated().reduce(into: initialInterpolation) { interpolation, element in
        if element.offset != 0 { interpolation.appendLiteral(separator) }
        interpolation.appendInterpolation(element.element)
    }

    return Text(LocalizedStringKey(stringInterpolation: interpolation))
}
