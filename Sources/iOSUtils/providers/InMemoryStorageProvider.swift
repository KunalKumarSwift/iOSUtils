/// Concrete storage provider that holds data in a process-lifetime dictionary.
///
/// Intended for unit tests and previews where persistence is undesirable.
/// Selected when IOSUTILS_STORAGE_PROVIDER=memory.
/// Thread-safe via a serial DispatchQueue.
///
/// Environment variables:
///   IOSUTILS_STORAGE_PROVIDER – set to "memory" to activate.
import Foundation

/// Stores and retrieves data in an in-process dictionary with no persistence.
public final class InMemoryStorageProvider: StorageProviding {

    // Serial queue makes reads/writes thread-safe without locks.
    private let _queue = DispatchQueue(label: "com.iosutils.inmemory.storage")
    private var _store: [String: Data] = [:]

    /// Initialise an empty in-memory store.
    public init() {}

    public func set(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { throw StorageError.encodingFailed }
        try set(data, forKey: key)
    }

    public func set(_ data: Data, forKey key: String) throws {
        _queue.sync { _store[key] = data }
    }

    public func string(forKey key: String) throws -> String {
        let raw = try data(forKey: key)
        guard let str = String(data: raw, encoding: .utf8) else { throw StorageError.decodingFailed }
        return str
    }

    public func data(forKey key: String) throws -> Data {
        try _queue.sync {
            guard let data = _store[key] else { throw StorageError.notFound }
            return data
        }
    }

    @discardableResult
    public func delete(forKey key: String) -> Bool {
        _queue.sync { _store.removeValue(forKey: key) != nil }
    }

    public func contains(key: String) -> Bool {
        _queue.sync { _store[key] != nil }
    }
}
