import Foundation

/// Property wrapper for type-safe UserDefaults access.
///
/// Usage:
///   @UserDefault(key: "username", defaultValue: "")
///   var username: String
@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let store: UserDefaults

    public init(key: String, defaultValue: T, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }

    public var wrappedValue: T {
        get { store.object(forKey: key) as? T ?? defaultValue }
        set { store.set(newValue, forKey: key) }
    }
}

@propertyWrapper
public struct UserDefaultOptional<T> {
    let key: String
    let store: UserDefaults

    public init(key: String, store: UserDefaults = .standard) {
        self.key = key
        self.store = store
    }

    public var wrappedValue: T? {
        get { store.object(forKey: key) as? T }
        set {
            if let value = newValue { store.set(value, forKey: key) }
            else { store.removeObject(forKey: key) }
        }
    }
}

/// Codable-based UserDefaults property wrapper for complex types.
@propertyWrapper
public struct UserDefaultCodable<T: Codable> {
    let key: String
    let defaultValue: T
    let store: UserDefaults
    let decoder: JSONDecoder
    let encoder: JSONEncoder

    public init(key: String, defaultValue: T, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    public var wrappedValue: T {
        get {
            guard let data = store.data(forKey: key),
                  let value = try? decoder.decode(T.self, from: data) else { return defaultValue }
            return value
        }
        set {
            if let data = try? encoder.encode(newValue) {
                store.set(data, forKey: key)
            }
        }
    }
}
