//
//  ContentView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 8/5/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct PairCell: View {

    let pair: Day.Pair
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        HStack() {

            if sizeCategory.isAccessibility {

                Rectangle()
                    .frame(width: 5)
                    .foregroundColor(pair.form.color)

                VStack(alignment: .leading) {
                    Text("\(pair.from)-\(pair.to)").font(.system(.callout, design: .monospaced))
                    Text(pair.subject).font(.headline).bold()
                    Text(pair.weeks).font(.caption)
                    Text(pair.note).font(.caption)
                }
            } else {

                VStack(alignment: .trailing) {
                    Text(pair.from).font(.system(.callout, design: .monospaced))
                    Text(pair.to).font(.system(.footnote, design: .monospaced))
                }

                Rectangle().frame(width: 2).foregroundColor(pair.form.color)

                VStack(alignment: .leading) {
                    HStack {
                        Text(pair.subject).font(.headline).bold()
                        Text("(\(pair.weeks))").font(.callout)
                    }
                    Text(pair.note).font(.callout)
                }
            }
            
            Spacer().layoutPriority(-1)

//            image
//                .resizable()
//                .scaledToFill()
//                .frame(width: 50, height: 50)
//                .clipShape(Circle())
        }
    }
}

extension Day.Pair.Form {

    var color: Color {
        switch self {
        case .lecture: return .green
        case .practice: return .red
        case .lab: return .yellow
        case .exam: return .purple
        case .unknown: return .gray
        }
    }
}

extension ContentSizeCategory {

    var isAccessibility: Bool { Self.accessibility.contains(self) }

    private static let accessibility: Set<ContentSizeCategory> = [
        .accessibilityMedium,
        .accessibilityLarge,
        .accessibilityExtraLarge,
        .accessibilityExtraExtraLarge,
        .accessibilityExtraExtraExtraLarge
    ]
}
