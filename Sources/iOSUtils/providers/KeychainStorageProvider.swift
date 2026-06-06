/// Concrete storage provider backed by the iOS Keychain.
///
/// Suitable for sensitive data (tokens, passwords). Selected when
/// IOSUTILS_STORAGE_PROVIDER=keychain. Operations are synchronous.
/// Guarded by `#if canImport(Security)` — not available on Linux.
///
/// Environment variables:
///   IOSUTILS_STORAGE_PROVIDER  – set to "keychain" to activate.
///   IOSUTILS_KEYCHAIN_SERVICE  – service name; defaults to the bundle ID.
///   IOSUTILS_KEYCHAIN_GROUP    – optional access group for shared keychain.
#if canImport(Security)
import Foundation
import Security

// Read at module load so values are stable for the process lifetime.
private let _service: String =
    ProcessInfo.processInfo.environment["IOSUTILS_KEYCHAIN_SERVICE"]
    ?? Bundle.main.bundleIdentifier
    ?? "com.iosutils.keychain"

private let _group: String? =
    ProcessInfo.processInfo.environment["IOSUTILS_KEYCHAIN_GROUP"]

/// Stores and retrieves data using the iOS Security framework Keychain.
public final class KeychainStorageProvider: StorageProviding {

    private let _service: String
    private let _group: String?

    /// Initialise the provider.
    ///
    /// - Parameters:
    ///   - service: Keychain service identifier; defaults to env var or bundle ID.
    ///   - group: Optional access group for cross-app keychain sharing.
    public init(service: String = _service, group: String? = _group) {
        self._service = service
        self._group = group
    }

    public func set(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { throw StorageError.encodingFailed }
        try set(data, forKey: key)
    }

    public func set(_ data: Data, forKey key: String) throws {
        var query = _baseQuery(forKey: key)
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let patch: [String: Any] = [kSecValueData as String: data]
            let patchStatus = SecItemUpdate(_baseQuery(forKey: key) as CFDictionary, patch as CFDictionary)
            guard patchStatus == errSecSuccess else { throw StorageError.systemError(patchStatus) }
        } else if status != errSecSuccess {
            throw StorageError.systemError(status)
        }
    }

    public func string(forKey key: String) throws -> String {
        let raw = try data(forKey: key)
        guard let str = String(data: raw, encoding: .utf8) else { throw StorageError.decodingFailed }
        return str
    }

    public func data(forKey key: String) throws -> Data {
        var query = _baseQuery(forKey: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { throw StorageError.notFound }
        guard status == errSecSuccess, let data = result as? Data else {
            throw StorageError.systemError(status)
        }
        return data
    }

    @discardableResult
    public func delete(forKey key: String) -> Bool {
        SecItemDelete(_baseQuery(forKey: key) as CFDictionary) == errSecSuccess
    }

    public func contains(key: String) -> Bool {
        SecItemCopyMatching(_baseQuery(forKey: key) as CFDictionary, nil) == errSecSuccess
    }

    private func _baseQuery(forKey key: String) -> [String: Any] {
        var q: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: _service,
            kSecAttrAccount as String: key
        ]
        if let g = _group { q[kSecAttrAccessGroup as String] = g }
        return q
    }
}
#endif
