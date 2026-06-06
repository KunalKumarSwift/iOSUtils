/// Selects and returns the active `StorageProviding` implementation.
///
/// Contains zero implementation logic — only reads the environment variable
/// and instantiates the correct provider. All storage logic lives in providers/.
/// To add a backend: create one conforming file, add one `case` below.
///
/// Environment variables:
///   IOSUTILS_STORAGE_PROVIDER – "userdefaults" | "keychain" | "memory"
///                               Defaults to "userdefaults".
import Foundation

// Read once at module load; stable for the process lifetime.
private let _providerKey: String =
    ProcessInfo.processInfo.environment["IOSUTILS_STORAGE_PROVIDER"]
    ?? "userdefaults"

/// Factory that vends the correct `StorageProviding` instance.
public enum StorageFacade {

    /// Return the storage provider configured by `IOSUTILS_STORAGE_PROVIDER`.
    ///
    /// - Returns: A fully initialised `StorageProviding` implementation.
    /// - Note: Always returns a valid provider; unknown values fall back to `UserDefaultsStorageProvider`.
    public static func makeProvider() -> StorageProviding {
        switch _providerKey.lowercased() {
        case "keychain": return KeychainStorageProvider()
        case "memory":   return InMemoryStorageProvider()
        default:         return UserDefaultsStorageProvider()
        }
    }
}
