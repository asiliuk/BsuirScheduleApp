import SwiftUI
import ScheduleCore

public enum PairViewForm: String, CaseIterable, Identifiable {
    public var id: Self { self }
    case lecture
    case practice
    case lab
    case exam
    case consultation
    case test
    case unknown
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
        case .test: return "view.pairView.form.name.test"
        case .unknown: return "view.pairView.form.name.unknown"
        }
    }

    public var symbolName: String {
        switch self {
        case .lecture: return "person.bust"
        case .lab: return "chart.xyaxis.line"
        case .practice: return "hammer"
        case .consultation: return "case"
        case .exam: return "graduationcap"
        case .test: return "pencil.and.ruler"
        case .unknown: return "questionmark"
        }
    }
}

// MARK: - PairViewModel.Form

extension PairViewModel.Form {

    public var name: LocalizedStringKey {
        switch self {
        case let .unknown(name?):
            "view.pairView.form.name.unknown.named\(name)"
        case let form:
            form.viewForm.name
        }
    }

    public var symbolName: String {
        viewForm.symbolName
    }

    public var viewForm: PairViewForm {
        switch self {
        case .exam: .exam
        case .consultation: .consultation
        case .lab: .lab
        case .lecture: .lecture
        case .practice: .practice
        case .test: .test
        case .unknown: .unknown
        }
    }
}
