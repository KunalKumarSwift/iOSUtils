/// Defines the contract for network connectivity monitoring providers.
///
/// Single-concern interface used by NetworkFacade to select the active
/// monitor via the IOSUTILS_NETWORK_PROVIDER env var.
/// The `onStatusChange` callback is always delivered on the main thread.
///
/// Environment variables: none (consumed by NetworkFacade).
import Foundation

/// Contract every network monitoring provider must satisfy.
public protocol NetworkMonitoring: AnyObject {

    /// Whether the device currently has network access.
    var isConnected: Bool { get }

    /// The interface type of the active connection.
    var connectionType: ConnectionType { get }

    /// Callback fired on the main thread when connectivity or type changes.
    ///
    /// - Note: Assign before calling `startMonitoring` to avoid missing the first event.
    var onStatusChange: NetworkStatusHandler? { get set }

    /// Begin observing network state changes.
    func startMonitoring()

    /// Stop observing and release any system resources held by the monitor.
    func stopMonitoring()
}
