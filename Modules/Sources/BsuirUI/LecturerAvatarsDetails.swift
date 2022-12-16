//
//  LecturerAvatarsDetails.swift
//  BsuirUI
//
//  Created by Anton Siliuk on 17.10.21.
//  Copyright © 2021 Saute. All rights reserved.
//

import SwiftUI
import BsuirApi

public struct LecturerAvatarsDetails: View {
    let lecturers: [Employee]
    let showDetails: (Employee) -> Void
    @ScaledMetric(relativeTo: .body) private var overlap: CGFloat = 24

    public init(
        lecturers: [Employee],
        showDetails: @escaping (Employee) -> Void
    ) {
        self.lecturers = lecturers
        self.showDetails = showDetails
    }

    public var body: some View {
        if lecturers.isEmpty {
            EmptyView()
        } else {
            HStack(spacing: -overlap) {
                ForEach(lecturers, id: \.id) { lecturer in
                    Avatar(url: lecturer.photoLink)
                }
            }
            .overlay {
                Menu {
                    ForEach(lecturers, id: \.id) { lecturer in
                        Button {
                            showDetails(lecturer)
                        } label: {
                            Text(lecturer.fio)
                        }
                    }
                } label: {
                    Color.clear
                }
            }
        }
    }
}
