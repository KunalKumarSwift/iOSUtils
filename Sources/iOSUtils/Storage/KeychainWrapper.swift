import Foundation
import Security

public enum KeychainError: LocalizedError {
    case unableToEncode
    case unableToDecode
    case itemNotFound
    case duplicateItem
    case unexpectedStatus(OSStatus)

    public var errorDescription: String? {
        switch self {
        case .unableToEncode: return "Unable to encode value for Keychain storage."
        case .unableToDecode: return "Unable to decode value from Keychain."
        case .itemNotFound: return "Keychain item not found."
        case .duplicateItem: return "Keychain item already exists."
        case .unexpectedStatus(let status): return "Unexpected Keychain status: \(status)."
        }
    }
}

public struct KeychainWrapper {

    private let service: String
    private let accessGroup: String?

    public init(service: String = Bundle.main.bundleIdentifier ?? "com.iosutils.keychain", accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    public func set(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { throw KeychainError.unableToEncode }
        try set(data, forKey: key)
    }

    public func set(_ data: Data, forKey key: String) throws {
        var query = baseQuery(forKey: key)
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(baseQuery(forKey: key) as CFDictionary, update as CFDictionary)
            guard updateStatus == errSecSuccess else { throw KeychainError.unexpectedStatus(updateStatus) }
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    public func string(forKey key: String) throws -> String {
        let data = try data(forKey: key)
        guard let string = String(data: data, encoding: .utf8) else { throw KeychainError.unableToDecode }
        return string
    }

    public func data(forKey key: String) throws -> Data {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
        guard let data = result as? Data else { throw KeychainError.unableToDecode }
        return data
    }

    @discardableResult
    public func delete(forKey key: String) -> Bool {
        SecItemDelete(baseQuery(forKey: key) as CFDictionary) == errSecSuccess
    }

    public func contains(key: String) -> Bool {
        let status = SecItemCopyMatching(baseQuery(forKey: key) as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func baseQuery(forKey key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        return query
    }
}
