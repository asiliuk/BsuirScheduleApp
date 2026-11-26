import Sharing
import BsuirCore

extension SharedKey where Self == AppStorageKey<Bool>.Default {
    public static var alwaysShowFormIcon: Self {
        Self[.appStorage(StorageKeys.pairFormAlwaysShowIconKey, store: .asiliukShared), default: false]
    }
}

extension SharedKey where Self == AppStorageKey<PairFormColor>.Default {
    public static func pairFormColor(for form: PairViewForm) -> Self {
        Self[.appStorage(form.colorDefaultsKey, store: .asiliukShared), default: form.defaultColor]
    }
}

extension PairViewForm {
    var colorDefaultsKey: String {
        "pair-form-color-\(rawValue)"
    }

    var legacyDefaultsKey: String {
        "pair-form-color.\(rawValue)"
    }
}

extension StorageKeys {
    public static let pairFormAlwaysShowIconKey = "pair-form-always-show-icon"
    public static let pairViewFormColorKeys = PairViewForm.allCases.map { $0.colorDefaultsKey }
}
