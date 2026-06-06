/// Value type representing all errors that can originate from storage providers.
///
/// Kept as a separate model file so both provider implementations and call
/// sites can import it without coupling to any concrete provider.
/// `OSStatus` is an Apple-only type (typealias for Int32); the `systemError`
/// case uses `Int32` directly so the enum compiles on Linux too.
///
/// Environment variables: none.
import Foundation

/// Errors thrown by any `StorageProviding` implementation.
public enum StorageError: LocalizedError, Equatable {

    /// No value is stored under the requested key.
    case notFound

    /// The stored bytes could not be decoded into the requested type.
    case decodingFailed

    /// The value could not be encoded for storage.
    case encodingFailed

    /// An unexpected system-level error occurred; the associated value is the raw status code.
    /// Uses `Int32` rather than `OSStatus` because `OSStatus` is unavailable on Linux.
    case systemError(Int32)

    public var errorDescription: String? {
        switch self {
        case .notFound:            return "No value found for the requested key."
        case .decodingFailed:      return "Stored data could not be decoded."
        case .encodingFailed:      return "Value could not be encoded for storage."
        case .systemError(let s):  return "Storage system error (status \(s))."
        }
    }
}
