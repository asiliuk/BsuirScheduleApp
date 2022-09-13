//
//  ScheduleIdentifierTitle.swift
//  ScheduleWidgetExtension
//
//  Created by Anton Siliuk on 06/09/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI

struct ScheduleIdentifierTitle: View {
    let title: String

    var body: some View {
        HStack {
            BsuirImage()
            Text(title).font(.subheadline).lineLimit(1)
        }
    }
}
