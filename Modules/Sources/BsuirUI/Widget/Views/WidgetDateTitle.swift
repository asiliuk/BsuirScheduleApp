//
//  WidgetDateTitle.swift
//  ScheduleWidgetExtension
//
//  Created by Anton Siliuk on 06/09/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI
import BsuirCore

struct WidgetDateTitle: View {
    let date: Date
    var isSmall: Bool = false

    var body: some View {
        Text(date.formatted(isSmall ? .widgetSmall : .widgetNormal))
            .lineLimit(1)
            .allowsTightening(true)
            .environment(\.locale, .current)
    }
}
