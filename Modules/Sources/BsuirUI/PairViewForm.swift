import SwiftUI
import ScheduleCore

public enum PairViewForm: String, CaseIterable, Identifiable {
    public var id: Self { self }
    case lecture
    case practice
    case lab
    case exam
    case consultation
    case unknown
}

// MARK: - PairViewModel.Form

public extension PairViewForm {
    init(_ form: PairViewModel.Form) {
        switch form {
        case .exam: self = .exam
        case .consultation: self = .consultation
        case .lab: self = .lab
        case .lecture: self = .lecture
        case .practice: self = .practice
        case .unknown: self = .unknown
        }
    }
}

// MARK: - Details

extension PairViewForm {
    public var name: LocalizedStringKey {
        switch self {
        case .lecture: return "view.pairView.form.name.lecture"
        case .lab: return "view.pairView.form.name.lab"
        case .practice: return "view.pairView.form.name.practice"
        case .consultation: return "view.pairView.form.name.consultation"
        case .exam: return "view.pairView.form.name.exam"
        case .unknown: return "view.pairView.form.name.unknown"
        }
    }

    var shortName: LocalizedStringKey {
        switch self {
        case .lecture: return "view.pairView.form.name.short.lecture"
        case .lab: return "view.pairView.form.name.short.lab"
        case .practice: return "view.pairView.form.name.short.practice"
        case .consultation: return "view.pairView.form.name.short.consultation"
        case .exam: return "view.pairView.form.name.short.exam"
        case .unknown: return "view.pairView.form.name.short.unknown"
        }
    }

    public var symbolName: String {
        switch self {
        case .lecture: return "person.bust"
        case .lab: return "chart.xyaxis.line"
        case .practice: return "hammer"
        case .consultation: return "case"
        case .exam: return "graduationcap"
        case .unknown: return "questionmark"
        }
    }

    @ViewBuilder public var shape: some View {
        switch self {
        case .lecture: Circle()
        case .practice: Rectangle()
        case .lab: Image(systemName: "triangle.fill").resizable()
        case .consultation: Image(systemName: "hexagon.fill").resizable()
        case .exam: Image(systemName: "star.fill").resizable()
        case .unknown: Image(systemName: "rhombus.fill").resizable()
        }
    }
}
