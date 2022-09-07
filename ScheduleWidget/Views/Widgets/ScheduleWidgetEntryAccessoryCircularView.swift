//
//  ScheduleWidgetEntryAccessoryCircularView.swift
//  ScheduleWidgetExtension
//
//  Created by Anton Siliuk on 06/09/2022.
//  Copyright © 2022 Saute. All rights reserved.
//

import SwiftUI
import BsuirCore

#if swift(>=5.7)
@available(iOS 16.0, *)
struct ScheduleWidgetEntryAccessoryCircularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        switch entry.content {
        case .needsConfiguration:
            Text("⚙️")
        case .pairs(_, []):
            NoPairsView()
        case let .pairs(passed, upcoming):
            let pairs = PairsToDisplay(
                passed: passed,
                upcoming: upcoming,
                maxVisibleCount: 1
            )
            
            ForEach(pairs.visible) { pair in
                PairDetailsView(progress: pair.progress) {
                    pair.subject.map(Text.init(verbatim:))
                } label: {
                    pair.auditory.map(Text.init(verbatim:))
                }
            }
        }
    }
}

@available(iOS 16.0, *)
private struct PairDetailsView<Content: View, Label: View>: View {
    @ObservedObject var progress: PairProgress
    @ViewBuilder let content: () -> Content
    @ViewBuilder let label: () -> Label
    
    var body: some View {
        return Gauge(value: progress.value) {
            label()
        } currentValueLabel: {
            content()
        }
        .gaugeStyle(.accessoryCircular)
    }
}
#endif
