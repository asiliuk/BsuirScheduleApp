import SwiftUI

public class PairFormColorService: ObservableObject {
    public init(storage: UserDefaults) {
        self.storage = storage
        storage.register(defaults: PairViewForm.colorDefaults)
    }
    
    public func color(for form: PairViewForm) -> Binding<PairFormColor> {
        return Binding(
            get: { [storage] in
                guard let color = storage.string(forKey: form.defaultsKey) else {
                    assertionFailure("Failed to get color for \(form)")
                    return .gray
                }
                
                guard let formColor = PairFormColor(rawValue: color) else {
                    assertionFailure("Failed to decode pair form color \(color)")
                    return .gray
                }
                
                return formColor
            },
            set: { [storage, objectWillChange] color in
                objectWillChange.send()
                storage.set(color.rawValue, forKey: form.defaultsKey)
            }
        )
    }
        
    private let storage: UserDefaults
}

private extension PairViewForm {
    static var colorDefaults: [String: Any] {
        return Dictionary(
            uniqueKeysWithValues: allCases.map { ($0.defaultsKey, $0.defaultColor.rawValue) }
        )
    }
    
    var defaultsKey: String {
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
