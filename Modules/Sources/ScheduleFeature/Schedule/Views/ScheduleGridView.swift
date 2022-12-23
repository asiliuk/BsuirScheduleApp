import SwiftUI
import BsuirUI
import BsuirApi
import ScheduleCore

public enum ScheduleGridViewPairDetails {
    case lecturers(show: (Employee) -> Void)
    case groups(show: (String) -> Void)
    case nothing
}

public enum ScheduleGridLoading {
    case loadMore(() -> Void)
    case finished
    case never
}

struct ScheduleGridView: View {
    let days: [ScheduleDayViewModel]
    var loading: ScheduleGridLoading
    var pairDetails: ScheduleGridViewPairDetails
    @Binding var isOnTop: Bool

    var body: some View {
        ScrollableToTopList(isOnTop: $isOnTop) {
            Group {
                ForEach(days) { day in
                    ScheduleDay(
                        title: day.title,
                        subtitle: day.subtitle,
                        isToday: day.isToday,
                        pairs: day.pairs,
                        details: pairDetails
                    )
                }

                switch loading {
                case let .loadMore(load):
                    PairPlaceholder()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onAppear(perform: load)
                case .finished:
                    NoMorePairsIndicator()

                case .never:
                    EmptyView()
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        // To disable cell celection
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoMorePairsIndicator: View {
    var body: some View {
        Text("screen.schedule.noMorePairs.title")
            .font(.headline)
            .frame(minWidth: 0, maxWidth: .infinity)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct ScheduleDay: View {
    let title: String
    let subtitle: String?
    let isToday: Bool
    let pairs: [PairViewModel]
    let details: ScheduleGridViewPairDetails

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(pairs) { pair in
                    PairCell(
                        pair: pair,
                        details: detailsView(pair: pair)
                    )
                }
            }
        } header: {
            ScheduleDateTitle(date: title, relativeDate: subtitle, isToday: isToday)
        }
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
