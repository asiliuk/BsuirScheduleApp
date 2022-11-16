import SwiftUI
import BsuirUI
import BsuirApi
import BsuirCore

struct ScheduleGridView: View {
    enum PairDetails {
        case lecturers(show: (Employee) -> Void)
        case groups(show: (String) -> Void)
        case nothing
    }

    let days: [ScheduleDayViewModel]
    var loadMore: (() -> Void)? = nil
    var pairDetails: PairDetails = .nothing
    @Binding var isOnTop: Bool

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(days) { day in
                    ScheduleDay(
                        title: day.title,
                        subtitle: day.subtitle,
                        isMostRelevant: day.isMostRelevant,
                        isToday: day.isToday,
                        pairs: day.pairs,
                        details: pairDetails
                    )
                }
                .listRowSeparator(.hidden)

                if let load = loadMore {
                    ProgressView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onAppear(perform: load)
                }
            }
            .listStyle(.plain)
            // To disable cell celection
            .buttonStyle(PlainButtonStyle())
            .onChange(of: isOnTop) { isOnTop in
                if isOnTop {
                    proxy.scrollTo(RelevantDayViewID.mostRelevant, anchor: .top)
                }
            }
            .gesture(DragGesture().onChanged { _ in
                isOnTop = false
            })
        }
    }
}

struct ScheduleDay: View {
    let title: String
    let subtitle: String?
    var isMostRelevant: Bool
    let isToday: Bool
    let pairs: [PairViewModel]
    let details: ScheduleGridView.PairDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScheduleDateTitle(date: title, relativeDate: subtitle, isToday: isToday)

            ForEach(pairs) { pair in
                PairCell(
                    pair: pair,
                    details: detailsView(pair: pair)
                )
            }
        }
        .id(isMostRelevant ? RelevantDayViewID.mostRelevant : .other)
        .padding(.vertical, 10)
    }

    @ViewBuilder private func detailsView(pair: PairViewModel) -> some View {
        switch details {
        case .lecturers(let show):
            LecturerAvatarsDetails(lecturers: pair.lecturers, showDetails: show)
        case .groups(let show):
            GroupPairDetails(groups: pair.groups, showDetails: show)
        case .nothing:
            EmptyView()
        }
    }

    @ViewBuilder private var titleText: some View {
        if let subtitle = subtitle {
            Text("\(Text(subtitle).foregroundColor(isToday ? .blue : .red)), \(title)")
        } else {
            Text(title)
        }
    }
}

private enum RelevantDayViewID: Hashable {
    case mostRelevant
    case other
}
