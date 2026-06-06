/// Tests for `MockNetworkProvider`.
///
/// Verifies that simulated connectivity changes update state and invoke the
/// callback synchronously, which tests can rely on without async overhead.
import XCTest
@testable import iOSUtils

final class MockNetworkProviderTests: XCTestCase {

    func testInitialState() {
        let provider = MockNetworkProvider(isConnected: false, connectionType: .cellular)
        XCTAssertFalse(provider.isConnected)
        XCTAssertEqual(provider.connectionType, .cellular)
    }

    func testSimulateChange_updatesState() {
        let provider = MockNetworkProvider()
        provider.simulateChange(isConnected: false, type: .unknown)
        XCTAssertFalse(provider.isConnected)
        XCTAssertEqual(provider.connectionType, .unknown)
    }

    func testSimulateChange_firesCallback() {
        let provider = MockNetworkProvider()
        var receivedConnected: Bool?
        var receivedType: ConnectionType?

        provider.onStatusChange = { connected, type in
            receivedConnected = connected
            receivedType = type
        }

        provider.simulateChange(isConnected: false, type: .ethernet)
        XCTAssertEqual(receivedConnected, false)
        XCTAssertEqual(receivedType, .ethernet)
    }

    func testStartAndStop_areNoOps() {
        let provider = MockNetworkProvider()
        provider.startMonitoring()
        provider.stopMonitoring()
    }
}
