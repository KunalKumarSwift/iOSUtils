/// Selects and returns the active `NetworkMonitoring` implementation.
///
/// Contains zero implementation logic — only reads the environment variable
/// and instantiates the correct provider. All monitoring logic lives in providers/.
/// To add a backend: create one conforming file, add one `case` below.
///
/// Environment variables:
///   IOSUTILS_NETWORK_PROVIDER – "nwpath" | "mock"
///                               Defaults to "nwpath".
import Foundation

// Read once at module load; stable for the process lifetime.
private let _providerKey: String =
    ProcessInfo.processInfo.environment["IOSUTILS_NETWORK_PROVIDER"]
    ?? "nwpath"

/// Factory that vends the correct `NetworkMonitoring` instance.
public enum NetworkFacade {

    /// Return the network monitor configured by `IOSUTILS_NETWORK_PROVIDER`.
    ///
    /// - Returns: A fully initialised `NetworkMonitoring` implementation.
    /// - Note: Unknown values fall back to `NWPathNetworkProvider`.
    public static func makeProvider() -> NetworkMonitoring {
        switch _providerKey.lowercased() {
        case "mock": return MockNetworkProvider()
        default:     return NWPathNetworkProvider()
        }
    }
}
