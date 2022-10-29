//
//  ColorCoder.swift
//  BsuirScheduleApp
//
//  Created by Nikita Prokhorchuk on 9.09.22.
//  Copyright © 2022 Saute. All rights reserved.
//

// See https://nilcoalescing.com/blog/EncodeAndDecodeSwiftUIColor/

import SwiftUI

public struct ColorCoder {
    public func encodeColor(_ color: Color) throws -> Data {
        if let codableColor = CodableColor(color: color) {
            return try JSONEncoder().encode(codableColor)
        } else {
            throw EncodingError.wrongColor
        }
    }
    
    public func decodeColor(from data: Data) throws -> Color {
        let codableColor = try JSONDecoder()
            .decode(CodableColor.self, from: data)
        return Color(codableColor: codableColor)
    }
    
    public init() { }
}

private enum EncodingError: Error {
    case wrongColor
}

extension Color {
    public init(codableColor: CodableColor) {
        switch codableColor {
        case .red: self = .red
        case .pink: self = .pink
        case .orange: self = .orange
        case .yellow: self = .yellow
        case .green: self = .green
        case .cyan: self = .cyan
        case .blue: self = .blue
        case .indigo: self = .indigo
        case .purple: self = .purple
        case .gray: self = .gray
        case .brown: self = .brown
        }
    }
}

public enum CodableColor: Codable, CaseIterable, Equatable {
    case red
    case pink
    case orange
    case yellow
    case green
    case cyan
    case blue
    case indigo
    case purple
    case gray
    case brown
    
    public init?(color: Color) {
        switch color {
        case .red: self = .red
        case .pink: self = .pink
        case .orange: self = .orange
        case .yellow: self = .yellow
        case .green: self = .green
        case .cyan: self = .cyan
        case .blue: self = .blue
        case .indigo: self = .indigo
        case .purple: self = .purple
        case .gray: self = .gray
        case .brown: self = .brown
        default: return nil
        }
    }
}
