//
//  BsuirImage.swift
//  ScheduleWidgetExtension
//
//  Created by Anton Siliuk on 07/09/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI

struct BsuirImage: View {
    var body: some View {
        Image("BsuirSymbol")
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
    }
}

