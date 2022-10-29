//
//  Color.swift
//  BsuirScheduleApp
//
//  Created by Nikita Prokhorchuk on 29.10.22.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI

extension Color {
    var descriptionLocalizedKey: LocalizedStringKey? {
        switch self {
        case .red:
            return "color.red"
        case .pink:
            return "color.pink"
        case .orange:
            return "color.orange"
        case .yellow:
            return "color.yellow"
        case .green:
            return "color.green"
        case .cyan:
            return "color.cyan"
        case .blue:
            return "color.blue"
        case .indigo:
            return "color.indigo"
        case .purple:
            return "color.purple"
        case .gray:
            return "color.gray"
        case .brown:
            return "color.brown"
        default:
            return nil
        }
    }
}
