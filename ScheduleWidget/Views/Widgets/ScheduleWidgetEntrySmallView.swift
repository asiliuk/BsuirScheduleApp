//
//  ScheduleWidgetEntrySmallView.swift
//  ScheduleWidgetExtension
//
//  Created by Anton Siliuk on 06/09/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI
import BsuirUI
import BsuirCore
import ScheduleCore

struct ScheduleWidgetEntrySmallView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ScheduleIdentifierTitle(title: entry.title)
                Spacer(minLength: 0)
            }

            WidgetDateTitle(date: entry.date, isSmall: true)

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

                Spacer(minLength: 0)
                ForEach(pairs.visible) { pair in
                    PairView(pair: pair, distribution: .vertical, isCompact: true)
                }
                Spacer(minLength: 0)

                RemainingPairsView(pairs: pairs.upcomingInvisible, visibleCount: 1, showTime: .hide)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}
