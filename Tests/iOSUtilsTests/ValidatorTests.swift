import XCTest
@testable import iOSUtils

final class ValidatorTests: XCTestCase {

    func testValidEmail() {
        XCTAssertTrue(Validator.email("user@example.com").isValid)
        XCTAssertFalse(Validator.email("bad-email").isValid)
    }

    func testPassword() {
        XCTAssertTrue(Validator.password("Password1").isValid)
        XCTAssertFalse(Validator.password("short").isValid)
        XCTAssertFalse(Validator.password("alllowercase1").isValid)
    }

    func testNotEmpty() {
        XCTAssertTrue(Validator.notEmpty("hello").isValid)
        XCTAssertFalse(Validator.notEmpty("  ").isValid)
    }

    func testCreditCard() {
        // Valid Luhn number
        XCTAssertTrue(Validator.creditCard("4532015112830366").isValid)
        XCTAssertFalse(Validator.creditCard("1234567890123456").isValid)
        XCTAssertFalse(Validator.creditCard("123").isValid)
    }

    func testCombine() {
        let result = Validator.combine(
            Validator.notEmpty("hello"),
            Validator.minLength("hello", min: 3)
        )
        XCTAssertTrue(result.isValid)

        let failing = Validator.combine(
            Validator.notEmpty("hi"),
            Validator.minLength("hi", min: 10)
        )
        XCTAssertFalse(failing.isValid)
    }

    func testURL() {
        XCTAssertTrue(Validator.url("https://example.com").isValid)
        XCTAssertFalse(Validator.url("not a url").isValid)
    }
}
