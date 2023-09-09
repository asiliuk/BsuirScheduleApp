import SwiftUI
import BsuirApi

public struct LecturerAvatarsDetails: View {
    let lecturers: [Employee]
    @ScaledMetric(relativeTo: .body) private var overlap: CGFloat = 24

    public init(lecturers: [Employee]) {
        self.lecturers = lecturers
    }

    public var body: some View {
        if !lecturers.isEmpty {
            HStack(spacing: -overlap) {
                ForEach(lecturers, id: \.id) { lecturer in
                    Avatar(url: lecturer.photoLink)
                }
            }
        }
    }
}
