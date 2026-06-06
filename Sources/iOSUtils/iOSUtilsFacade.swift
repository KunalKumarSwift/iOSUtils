/// The single public entry point for the iOSUtils library.
///
/// Coordinates sub-facades to expose one lazily-initialised instance of each
/// provider. Clients import `iOSUtils` and use `iOSUtilsFacade.shared` —
/// they never import from `providers/` or `facades/` directly.
///
/// Provider selection is driven entirely by environment variables; see each
/// sub-facade for the variable name and accepted values.
///
/// Environment variables (via sub-facades):
///   IOSUTILS_STORAGE_PROVIDER  – storage backend selection.
///   IOSUTILS_NETWORK_PROVIDER  – network monitor selection.
///   IOSUTILS_HAPTICS_PROVIDER  – haptics provider selection.
///   IOSUTILS_ALERT_PROVIDER    – alert presenter selection.
///   IOSUTILS_VALIDATOR_PROVIDER – validator selection.
import Foundation

/// Coordinates all sub-facades and exposes provider instances to clients.
public final class iOSUtilsFacade {

    /// The library-wide shared instance.
    public static let shared = iOSUtilsFacade()

    /// Active storage backend; selected by `StorageFacade`.
    public let storage: StorageProviding

    /// Active network monitor; selected by `NetworkFacade`.
    public let network: NetworkMonitoring

    /// Active input validator; selected by `ValidatorFacade`.
    public let validator: ValidatorProviding

    #if canImport(UIKit)
    /// Active haptics provider; selected by `HapticsFacade`.
    public let haptics: HapticsProviding

    /// Active alert presenter; selected by `AlertFacade`.
    public let alerts: AlertPresenting
    #endif

    private init() {
        storage   = StorageFacade.makeProvider()
        network   = NetworkFacade.makeProvider()
        validator = ValidatorFacade.makeProvider()
        #if canImport(UIKit)
        haptics = HapticsFacade.makeProvider()
        alerts  = AlertFacade.makeProvider()
        #endif
    }
}
