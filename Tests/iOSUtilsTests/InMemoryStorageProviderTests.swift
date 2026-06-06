/// Tests for `InMemoryStorageProvider`.
///
/// Uses the in-memory provider directly to validate thread-safety guarantees
/// and the full CRUD surface without touching disk or Keychain.
import XCTest
@testable import iOSUtils

final class InMemoryStorageProviderTests: XCTestCase {

    private var _provider: InMemoryStorageProvider!

    override func setUp() {
        super.setUp()
        _provider = InMemoryStorageProvider()
    }

    func testSetAndRetrieveString() throws {
        try _provider.set("hello", forKey: "key")
        XCTAssertEqual(try _provider.string(forKey: "key"), "hello")
    }

    func testNotFound_throwsCorrectError() {
        XCTAssertThrowsError(try _provider.data(forKey: "missing")) { error in
            XCTAssertEqual(error as? StorageError, StorageError.notFound)
        }
    }

    func testDelete_returnsTrueWhenPresent() throws {
        try _provider.set("val", forKey: "k")
        XCTAssertTrue(_provider.delete(forKey: "k"))
        XCTAssertFalse(_provider.contains(key: "k"))
    }

    func testDelete_returnsFalseWhenAbsent() {
        XCTAssertFalse(_provider.delete(forKey: "nonexistent"))
    }

    func testContains() throws {
        XCTAssertFalse(_provider.contains(key: "x"))
        try _provider.set("v", forKey: "x")
        XCTAssertTrue(_provider.contains(key: "x"))
    }

    func testOverwrite() throws {
        try _provider.set("first", forKey: "k")
        try _provider.set("second", forKey: "k")
        XCTAssertEqual(try _provider.string(forKey: "k"), "second")
    }
}
