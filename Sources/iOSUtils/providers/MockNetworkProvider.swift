/// Concrete network monitoring provider that simulates connectivity for tests.
///
/// Exposes `simulateChange` so tests can drive status transitions without
/// touching the network stack. Selected when IOSUTILS_NETWORK_PROVIDER=mock.
///
/// Environment variables:
///   IOSUTILS_NETWORK_PROVIDER – set to "mock" to activate.
import Foundation

/// Simulates network connectivity; intended for unit tests and Xcode Previews.
public final class MockNetworkProvider: NetworkMonitoring {

    public var isConnected: Bool
    public var connectionType: ConnectionType
    public var onStatusChange: NetworkStatusHandler?

    /// Initialise with a given simulated state.
    ///
    /// - Parameters:
    ///   - isConnected: Initial simulated connectivity; defaults to `true`.
    ///   - connectionType: Initial simulated interface type; defaults to `.wifi`.
    public init(isConnected: Bool = true, connectionType: ConnectionType = .wifi) {
        self.isConnected = isConnected
        self.connectionType = connectionType
    }

    public func startMonitoring() {}
    public func stopMonitoring() {}

    /// Drive a simulated connectivity change and fire `onStatusChange`.
    ///
    /// - Parameters:
    ///   - isConnected: New simulated connectivity value.
    ///   - type: New simulated interface type.
    /// - Note: Invokes the callback synchronously on the caller's thread,
    ///         unlike the real provider which dispatches to the main thread.
    public func simulateChange(isConnected: Bool, type: ConnectionType) {
        self.isConnected = isConnected
        self.connectionType = type
        onStatusChange?(isConnected, type)
    }
}
