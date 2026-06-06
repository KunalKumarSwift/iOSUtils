/// Selects and returns the active `AlertPresenting` implementation.
///
/// Contains zero implementation logic — only reads the environment variable
/// and instantiates the correct provider. All presentation logic lives in providers/.
/// To add a backend: create one conforming file, add one `case` below.
///
/// Environment variables:
///   IOSUTILS_ALERT_PROVIDER – "uikit" (only option currently)
///                             Defaults to "uikit".
#if canImport(UIKit)
import Foundation

// Read once at module load; stable for the process lifetime.
private let _providerKey: String =
    ProcessInfo.processInfo.environment["IOSUTILS_ALERT_PROVIDER"]
    ?? "uikit"

/// Factory that vends the correct `AlertPresenting` instance.
public enum AlertFacade {

    /// Return the alert presenter configured by `IOSUTILS_ALERT_PROVIDER`.
    ///
    /// - Returns: A fully initialised `AlertPresenting` implementation.
    /// - Note: Unknown values fall back to `UIKitAlertProvider`.
    public static func makeProvider() -> AlertPresenting {
        // Currently only one concrete provider; the switch is the extension point.
        switch _providerKey.lowercased() {
        default: return UIKitAlertProvider()
        }
    }
}
#endif
