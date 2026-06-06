/// Value types describing the current state of the network connection.
///
/// Separated from the monitoring protocol so UI layers can depend only
/// on these lightweight types without importing provider internals.
///
/// Environment variables: none.
import Foundation

/// The physical interface type of the active network connection.
public enum ConnectionType: Equatable {
    case wifi
    case cellular
    case ethernet
    case unknown
}

/// A snapshot of network connectivity at a point in time.
public struct NetworkStatus: Equatable {

    /// Whether any usable network path is available.
    public let isConnected: Bool

    /// The interface carrying the active connection.
    public let connectionType: ConnectionType

    /// Initialise a network status snapshot.
    ///
    /// - Parameters:
    ///   - isConnected: `true` when a usable path exists.
    ///   - connectionType: The active interface type.
    public init(isConnected: Bool, connectionType: ConnectionType) {
        self.isConnected = isConnected
        self.connectionType = connectionType
    }
}

/// Callback type for network status change events, always delivered on the main thread.
public typealias NetworkStatusHandler = (_ isConnected: Bool, _ type: ConnectionType) -> Void
