/// Selects and returns the active `ValidatorProviding` implementation.
///
/// Contains zero implementation logic — only reads the environment variable
/// and instantiates the correct provider. All validation logic lives in providers/.
/// To add a backend: create one conforming file, add one `case` below.
///
/// Environment variables:
///   IOSUTILS_VALIDATOR_PROVIDER – "standard" (only option currently)
///                                 Defaults to "standard".
import Foundation

// Read once at module load; stable for the process lifetime.
private let _providerKey: String =
    ProcessInfo.processInfo.environment["IOSUTILS_VALIDATOR_PROVIDER"]
    ?? "standard"

/// Factory that vends the correct `ValidatorProviding` instance.
public enum ValidatorFacade {

    /// Return the validator configured by `IOSUTILS_VALIDATOR_PROVIDER`.
    ///
    /// - Returns: A fully initialised `ValidatorProviding` implementation.
    /// - Note: Unknown values fall back to `StandardValidatorProvider`.
    public static func makeProvider() -> ValidatorProviding {
        // Currently only one concrete provider; the switch is the extension point.
        switch _providerKey.lowercased() {
        default: return StandardValidatorProvider()
        }
    }
}
