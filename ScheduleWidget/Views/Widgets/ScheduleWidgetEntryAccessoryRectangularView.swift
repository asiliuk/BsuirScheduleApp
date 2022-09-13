//
//  ScheduleWidgetEntryAccessoryRectangularView.swift
//  ScheduleWidgetExtension
//
//  Created by Anton Siliuk on 07/09/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI
import BsuirUI
import BsuirCore

#if swift(>=5.7)
@available(iOS 16.0, *)
struct ScheduleWidgetEntryAccessoryRectangularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        switch entry.content {
        case .needsConfiguration:
            NeedsConfigurationView()
        case .pairs(_, []):
            NoPairsView()
        case let .pairs(passed, upcoming):
            let pairs = PairsToDisplay(
                passed: passed,
                upcoming: upcoming,
                maxVisibleCount: 1
            )
            
            ForEach(pairs.visible) { pair in
                PairView(
                    pair: pair,
                    distribution: .vertical,
                    isCompact: true,
                    spellForm: true
                )
            }
        }
    }
}
#endif
