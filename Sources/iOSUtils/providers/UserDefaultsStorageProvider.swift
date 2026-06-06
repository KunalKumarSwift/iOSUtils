/// Concrete storage provider backed by `UserDefaults`.
///
/// Suitable for non-sensitive user preferences. Selected when
/// IOSUTILS_STORAGE_PROVIDER=userdefaults (the default).
/// All operations are synchronous and execute on the caller's thread.
///
/// Environment variables:
///   IOSUTILS_STORAGE_PROVIDER – set to "userdefaults" to activate (default).
import Foundation

// Read at module load so the value is stable for the process lifetime.
private let _suite: String? = ProcessInfo.processInfo.environment["IOSUTILS_USERDEFAULTS_SUITE"]

/// Stores and retrieves UTF-8 strings and raw data using `UserDefaults`.
public final class UserDefaultsStorageProvider: StorageProviding {

    private let _store: UserDefaults

    /// Initialise the provider.
    ///
    /// - Parameter store: The `UserDefaults` suite to use; pass `nil` to resolve
    ///   from `IOSUTILS_USERDEFAULTS_SUITE`, falling back to `.standard`.
    public init(store: UserDefaults? = nil) {
        // Private file-scope constants cannot be used as public default-parameter values;
        // resolve here in the body instead.
        _store = store ?? _suite.flatMap(UserDefaults.init) ?? .standard
    }

    public func set(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { throw StorageError.encodingFailed }
        try set(data, forKey: key)
    }

    public func set(_ data: Data, forKey key: String) throws {
        _store.set(data, forKey: key)
    }

    public func string(forKey key: String) throws -> String {
        let raw = try data(forKey: key)
        guard let str = String(data: raw, encoding: .utf8) else { throw StorageError.decodingFailed }
        return str
    }

    public func data(forKey key: String) throws -> Data {
        guard let data = _store.data(forKey: key) else { throw StorageError.notFound }
        return data
    }

    @discardableResult
    public func delete(forKey key: String) -> Bool {
        guard _store.object(forKey: key) != nil else { return false }
        _store.removeObject(forKey: key)
        return true
    }

    public func contains(key: String) -> Bool {
        _store.object(forKey: key) != nil
    }
}
