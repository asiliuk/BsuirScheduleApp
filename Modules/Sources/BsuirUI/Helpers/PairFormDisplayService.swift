import SwiftUI
import BsuirCore
import WidgetKit

public class PairFormDisplayService: ObservableObject {
    private let storage: UserDefaults
    private let widgetService: WidgetService
    private lazy var alwaysShowFormIconStorage = storage.persistedBool(forKey: "pair-form-always-show-icon")

    public static let noop = PairFormDisplayService(storage: .standard, widgetService: .noop)

    public init(storage: UserDefaults, widgetService: WidgetService) {
        self.storage = storage
        self.widgetService = widgetService
        storage.register(
            defaults: Dictionary(
                uniqueKeysWithValues: PairViewForm.allCases.map { form in
                    (form.colorDefaultsKey, form.defaultColor.rawValue)
                }
            )
        )
    }

    public var alwaysShowFormIcon: Bool {
        get { alwaysShowFormIconStorage.value }
        set { updatingPairDisplay { alwaysShowFormIconStorage.value = newValue } }
    }

    public func color(for form: PairViewForm) -> PairFormColor {
        guard let color = storage.string(forKey: form.colorDefaultsKey) else {
            assertionFailure("Failed to get color for \(form)")
            return .gray
        }

        guard let formColor = PairFormColor(rawValue: color) else {
            assertionFailure("Failed to decode pair form color \(color)")
            return .gray
        }

        return formColor
    }

    public func setColor(_ color: PairFormColor?, for form: PairViewForm) {
        updatingPairDisplay {
            storage.set(color?.rawValue, forKey: form.colorDefaultsKey)
        }
    }
    
    public var areDefaultColors: Bool {
        PairViewForm.allCases
            .allSatisfy { color(for: $0) == $0.defaultColor }
    }
    
    public func resetColors() {
        updatingPairDisplay {
            for form in PairViewForm.allCases {
                self.setColor(nil, for: form)
            }
        }
    }
}

// MARK: - Helpers

private extension PairFormDisplayService {
    func updatingPairDisplay(_ update: () -> Void) {
        objectWillChange.send()
        update()
        // Make sure widget UI is also updated
        widgetService.reloadAll()
    }
}

private extension PairViewForm {
    var colorDefaultsKey: String {
        "pair-form-color.\(rawValue)"
    }
    
    var defaultColor: PairFormColor {
        switch self {
        case .lecture:
            return .green
        case .practice:
            return .red
        case .lab:
            return .yellow
        case .consultation:
            return .brown
        case .exam:
            return .purple
        case .unknown:
            return .gray
        }
    }
}
