import Network
import Foundation

/// Monitors network connectivity using NWPathMonitor.
/// Subscribe to `isConnectedPublisher` (Combine) or observe `isConnected` on main thread.
public final class NetworkMonitor {

    public static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.iosutils.networkmonitor")

    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown

    public var onStatusChange: ((Bool, ConnectionType) -> Void)?

    public enum ConnectionType {
        case wifi, cellular, ethernet, unknown
    }

    private init() {}

    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            let type = self.connectionType(for: path)
            DispatchQueue.main.async {
                self.isConnected = connected
                self.connectionType = type
                self.onStatusChange?(connected, type)
            }
        }
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }

    private func connectionType(for path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .unknown
    }
}
