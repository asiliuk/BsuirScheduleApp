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

// TODO: (watch) Move to shared place

extension PairViewForm {
    public var name: LocalizedStringResource {
        switch self {
        case .lecture: .viewPairViewFormNameLecture
        case .lab: .viewPairViewFormNameLab
        case .practice: .viewPairViewFormNamePractice
        case .consultation: .viewPairViewFormNameConsultation
        case .exam: .viewPairViewFormNameExam
        case .test: .viewPairViewFormNameTest
        case .unknown: .viewPairViewFormNameUnknown
        }
    }

    public var symbolName: String {
        switch self {
        case .lecture: "person.bust"
        case .lab: "chart.xyaxis.line"
        case .practice: "hammer"
        case .consultation: "case"
        case .exam: "graduationcap"
        case .test: "pencil.and.ruler"
        case .unknown: "questionmark"
        }
    }

    public var defaultColor: PairFormColor {
        switch self {
        case .lecture: .green
        case .practice: .red
        case .lab: .yellow
        case .consultation: .brown
        case .exam: .purple
        case .test: .indigo
        case .unknown: .gray
        }
    }
}

// MARK: - PairViewModel.Form

extension PairViewModel.Form {

    public var name: LocalizedStringResource {
        switch self {
        case let .unknown(name?):
            .viewPairViewFormNameUnknownNamed(name)
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
