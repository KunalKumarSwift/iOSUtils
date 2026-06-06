/// Tests for `StandardValidatorProvider` via the `ValidatorFacade`.
///
/// Exercises each validation method including the Luhn credit-card check.
/// All tests use the facade so switching to a custom provider is transparent.
import XCTest
@testable import iOSUtils

final class ValidatorTests: XCTestCase {

    private var _validator: ValidatorProviding!

    override func setUp() {
        super.setUp()
        _validator = ValidatorFacade.makeProvider()
    }

    func testValidEmail() {
        XCTAssertTrue(_validator.email("user@example.com").isValid)
        XCTAssertFalse(_validator.email("notanemail").isValid)
        XCTAssertFalse(_validator.email("@missing.com").isValid)
    }

    func testPassword_tooShort() {
        let result = _validator.password("Ab1", minLength: 8, requireUppercase: true,
                                         requireDigit: true, requireSpecial: false)
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.errorMessage)
    }

    func testPassword_missingUppercase() {
        let result = _validator.password("alllower1", minLength: 8, requireUppercase: true,
                                          requireDigit: true, requireSpecial: false)
        XCTAssertFalse(result.isValid)
    }

    func testPassword_valid() {
        XCTAssertTrue(
            _validator.password("Password1", minLength: 8, requireUppercase: true,
                                requireDigit: true, requireSpecial: false).isValid
        )
    }

    func testNotEmpty() {
        XCTAssertTrue(_validator.notEmpty("hello", fieldName: "Name").isValid)
        XCTAssertFalse(_validator.notEmpty("  ", fieldName: "Name").isValid)
    }

    func testCreditCard_validLuhn() {
        XCTAssertTrue(_validator.creditCard("4532015112830366").isValid)
    }

    func testCreditCard_invalidLuhn() {
        XCTAssertFalse(_validator.creditCard("1234567890123456").isValid)
    }

    func testCreditCard_tooShort() {
        XCTAssertFalse(_validator.creditCard("123").isValid)
    }

    func testURL_valid() {
        XCTAssertTrue(_validator.url("https://example.com").isValid)
    }

    func testURL_invalid() {
        XCTAssertFalse(_validator.url("not a url").isValid)
    }
}
