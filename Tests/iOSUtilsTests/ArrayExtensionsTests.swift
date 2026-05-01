import XCTest
@testable import iOSUtils

final class ArrayExtensionsTests: XCTestCase {

    func testSafeSubscript() {
        let arr = [1, 2, 3]
        XCTAssertEqual(arr[safe: 0], 1)
        XCTAssertNil(arr[safe: 5])
    }

    func testChunked() {
        let arr = [1, 2, 3, 4, 5]
        XCTAssertEqual(arr.chunked(into: 2), [[1, 2], [3, 4], [5]])
        XCTAssertEqual(arr.chunked(into: 0), [])
    }

    func testUnique() {
        let arr = [1, 2, 2, 3, 3, 3]
        XCTAssertEqual(arr.unique(), [1, 2, 3])
    }

    func testFrequency() {
        let arr = ["a", "b", "a", "c", "b", "a"]
        let freq = arr.frequency()
        XCTAssertEqual(freq["a"], 3)
        XCTAssertEqual(freq["b"], 2)
        XCTAssertEqual(freq["c"], 1)
    }

    func testRemoving() {
        let arr = [1, 2, 3, 2, 4]
        XCTAssertEqual(arr.removing(2), [1, 3, 4])
    }

    func testIsNotEmpty() {
        XCTAssertTrue([1].isNotEmpty)
        XCTAssertFalse([].isNotEmpty)
    }
}
