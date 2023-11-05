import SwiftUI

struct ScheduleSubgroupLabel: View {
    let subgroup: Int?
    var body: some View {
        if let subgroup {
            HStack(alignment: .top, spacing: 0) {
                Image(systemName: "person.fill")
                Text("\(subgroup)")
            }
            .font(.caption)
        }
    }
}
