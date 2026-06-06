import XCTest
@testable import iOSUtils

final class DateExtensionsTests: XCTestCase {

    func testIsToday() {
        XCTAssertTrue(Date().isToday)
        XCTAssertFalse(Date().adding(.day, value: -1).isToday)
    }

    func testIsInFuture() {
        XCTAssertTrue(Date().adding(.day, value: 1).isInFuture)
        XCTAssertFalse(Date().adding(.day, value: -1).isInFuture)
    }

    func testDaysBetween() {
        let today = Date()
        let nextWeek = today.adding(.day, value: 7)
        XCTAssertEqual(today.daysBetween(nextWeek), 7)
    }

    func testFormatted() {
        let date = Date.from(string: "2024-01-15", format: "yyyy-MM-dd")
        XCTAssertNotNil(date)
        XCTAssertEqual(date?.formatted("yyyy-MM-dd"), "2024-01-15")
    }

    func testStartOfDay() {
        let date = Date()
        let start = date.startOfDay
        let cal = Calendar.current
        XCTAssertEqual(cal.component(.hour, from: start), 0)
        XCTAssertEqual(cal.component(.minute, from: start), 0)
        XCTAssertEqual(cal.component(.second, from: start), 0)
    }
}
