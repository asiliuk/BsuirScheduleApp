//
//  Formatters.swift
//  
//
//  Created by Anton Siliuk on 20/08/2022.
//

import Foundation

extension FormatStyle where Self == Date.FormatStyle {
    public static var pairTime: Date.FormatStyle {
        Date.FormatStyle()
            .hour(.twoDigits(amPM: .abbreviated))
            .minute(.twoDigits)
    }
}
