/// Selects and returns the active `HapticsProviding` implementation.
///
/// Contains zero implementation logic — only reads the environment variable
/// and instantiates the correct provider. All haptic logic lives in providers/.
/// To add a backend: create one conforming file, add one `case` below.
///
/// Environment variables:
///   IOSUTILS_HAPTICS_PROVIDER – "uikit" | "mock"
///                               Defaults to "uikit".
#if canImport(UIKit)
import Foundation

// Read once at module load; stable for the process lifetime.
private let _providerKey: String =
    ProcessInfo.processInfo.environment["IOSUTILS_HAPTICS_PROVIDER"]
    ?? "uikit"

/// Factory that vends the correct `HapticsProviding` instance.
public enum HapticsFacade {

    /// Return the haptics provider configured by `IOSUTILS_HAPTICS_PROVIDER`.
    ///
    /// - Returns: A fully initialised `HapticsProviding` implementation.
    /// - Note: Unknown values fall back to `UIKitHapticsProvider`.
    public static func makeProvider() -> HapticsProviding {
        switch _providerKey.lowercased() {
        case "mock": return MockHapticsProvider()
        default:     return UIKitHapticsProvider()
        }
    }
}
#endif
