/// Defines the contract for all key-value persistent storage backends.
///
/// Single-concern interface used by StorageFacade to select the active
/// backend at startup via the IOSUTILS_STORAGE_PROVIDER env var.
/// Adding a new backend requires only one new file conforming to this
/// protocol and one branch in StorageFacade — nothing else changes.
///
/// Environment variables: none (consumed by StorageFacade).
import Foundation

/// Contract every storage backend must satisfy.
public protocol StorageProviding {

    /// Persist a UTF-8 string for a given key, overwriting any existing value.
    ///
    /// - Parameters:
    ///   - value: The string to store.
    ///   - key: Unique storage identifier.
    /// - Throws: `StorageError` on write failure.
    func set(_ value: String, forKey key: String) throws

    /// Persist raw bytes for a given key, overwriting any existing value.
    ///
    /// - Parameters:
    ///   - data: The bytes to store.
    ///   - key: Unique storage identifier.
    /// - Throws: `StorageError` on write failure.
    func set(_ data: Data, forKey key: String) throws

    /// Retrieve the UTF-8 string stored under a key.
    ///
    /// - Parameter key: Unique storage identifier.
    /// - Returns: The stored string.
    /// - Throws: `StorageError.notFound` when the key is absent,
    ///           `StorageError.decodingFailed` when bytes are not valid UTF-8.
    func string(forKey key: String) throws -> String

    /// Retrieve raw bytes stored under a key.
    ///
    /// - Parameter key: Unique storage identifier.
    /// - Returns: The stored data.
    /// - Throws: `StorageError.notFound` when the key is absent.
    func data(forKey key: String) throws -> Data

    /// Remove the value for a given key.
    ///
    /// - Parameter key: Unique storage identifier.
    /// - Returns: `true` if a value was removed; `false` if the key was not present.
    @discardableResult
    func delete(forKey key: String) -> Bool

    /// Check whether any value is stored under a key.
    ///
    /// - Parameter key: Unique storage identifier.
    /// - Returns: `true` when a value exists.
    func contains(key: String) -> Bool
}
