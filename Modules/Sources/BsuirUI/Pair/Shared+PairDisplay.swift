import Sharing

extension SharedKey where Self == AppStorageKey<Bool>.Default {
    public static var alwaysShowFormIcon: Self {
        Self[.appStorage("pair-form-always-show-icon", store: .asiliukShared), default: false]
    }
}
