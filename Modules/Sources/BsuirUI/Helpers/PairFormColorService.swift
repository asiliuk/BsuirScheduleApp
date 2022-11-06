import SwiftUI
import WidgetKit

public class PairFormColorService: ObservableObject {
    public init(storage: UserDefaults, widgetCenter: WidgetCenter = .shared) {
        self.storage = storage
        self.widgetCenter = widgetCenter
        storage.register(
            defaults: Dictionary(
                uniqueKeysWithValues: PairViewForm.allCases.map { form in
                    (form.colorDefaultsKey, form.defaultColor.rawValue)
                }
            )
        )
    }
    
    public func color(for form: PairViewForm) -> Binding<PairFormColor> {
        return Binding(
            get: { [unowned self] in self.color(for: form) },
            set: { [unowned self] color in
                updatingColors {
                    self.setColor(color, for: form)
                }
            }
        )
    }
    
    public var areDefaultColors: Bool {
        PairViewForm.allCases
            .allSatisfy { color(for: $0) == $0.defaultColor }
    }
    
    public func reset() {
        // To prevent SwiftUI from complaining that object is changed during view update
        // this is wrapped in async call
        DispatchQueue.main.async {
            self.updatingColors {
                for form in PairViewForm.allCases {
                    self.setColor(nil, for: form)
                }
            }
        }
    }
    
    private func color(for form: PairViewForm) -> PairFormColor {
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
    
    private func setColor(_ color: PairFormColor?, for form: PairViewForm) {
        storage.set(color?.rawValue, forKey: form.colorDefaultsKey)
    }
    
    private func updatingColors(_ update: () -> Void) {
        objectWillChange.send()
        update()
        // Make sure widget UI is also updated
        widgetCenter.reloadTimelines(ofKind: "ScheduleWidget")
    }
        
    private let storage: UserDefaults
    private let widgetCenter: WidgetCenter
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
        case .exam:
            return .purple
        case .unknown:
            return .gray
        }
    }
}
