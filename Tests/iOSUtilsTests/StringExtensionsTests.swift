import XCTest
@testable import iOSUtils

final class StringExtensionsTests: XCTestCase {

    func testIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("   ".isBlank)
        XCTAssertFalse("hello".isBlank)
    }

    func testTrimmed() {
        XCTAssertEqual("  hello  ".trimmed, "hello")
    }

    func testIsValidEmail() {
        XCTAssertTrue("user@example.com".isValidEmail)
        XCTAssertFalse("notanemail".isValidEmail)
        XCTAssertFalse("@missing.com".isValidEmail)
    }

    func testTruncated() {
        XCTAssertEqual("Hello World".truncated(to: 5), "Hello...")
        XCTAssertEqual("Hi".truncated(to: 5), "Hi")
    }

    func testCamelCased() {
        XCTAssertEqual("hello-world".camelCased(), "helloworld")
        XCTAssertEqual("my variable name".camelCased(), "myVariableName")
    }

    func testSnakeCased() {
        XCTAssertEqual("myVariableName".snakeCased(), "my_variable_name")
    }

    func testBase64RoundTrip() {
        let original = "Hello, iOSUtils!"
        let encoded = original.base64Encoded
        XCTAssertNotNil(encoded)
        XCTAssertEqual(encoded?.base64Decoded, original)
    }

    func testToInt() {
        XCTAssertEqual("42".toInt, 42)
        XCTAssertNil("abc".toInt)
    }

    func testSafeSubscript() {
        let str = "Hello"
        XCTAssertEqual(str[safe: 0], "H")
        XCTAssertNil(str[safe: 10])
    }
}
