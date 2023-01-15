import Foundation

@propertyWrapper
struct UserDefault<T> {

    let key: String
    let defaultValue: T
    let defaults = UserDefaults(suiteName: "group.com.wakey.userdefault")

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            self.defaults?.synchronize()
            return self.defaults?.object(forKey: self.key) as? T ?? self.defaultValue
        }
        set {
            self.defaults?.set(newValue, forKey: self.key)
            self.defaults?.synchronize()
        }
    }

}
