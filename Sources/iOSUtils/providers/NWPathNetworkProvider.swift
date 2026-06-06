/// Concrete network monitoring provider using Apple's Network framework.
///
/// Uses `NWPathMonitor` to observe connectivity changes. Selected when
/// IOSUTILS_NETWORK_PROVIDER=nwpath (the default on device).
/// Guarded by `#if canImport(Network)` — not available on Linux.
/// Status changes are always dispatched to the main thread before invoking
/// `onStatusChange`.
///
/// Environment variables:
///   IOSUTILS_NETWORK_PROVIDER – set to "nwpath" to activate (default).
#if canImport(Network)
import Network
import Foundation

/// Monitors network reachability via `NWPathMonitor`.
public final class NWPathNetworkProvider: NetworkMonitoring {

    private let _monitor = NWPathMonitor()
    private let _queue = DispatchQueue(label: "com.iosutils.network.nwpath")

    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    public var onStatusChange: NetworkStatusHandler?

    /// Initialise the provider. Call `startMonitoring()` to begin observation.
    public init() {}

    public func startMonitoring() {
        _monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            let type = self._resolveType(from: path)
            DispatchQueue.main.async {
                self.isConnected = connected
                self.connectionType = type
                self.onStatusChange?(connected, type)
            }
        }
        _monitor.start(queue: _queue)
    }

    public func stopMonitoring() {
        _monitor.cancel()
    }

    private func _resolveType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi)          { return .wifi }
        if path.usesInterfaceType(.cellular)       { return .cellular }
        if path.usesInterfaceType(.wiredEthernet)  { return .ethernet }
        return .unknown
    }
}
#endif
