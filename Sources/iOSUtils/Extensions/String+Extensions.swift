/// Value-level helpers added to `String` for common iOS tasks.
///
/// All helpers are pure functions or computed properties with no side effects.
/// No environment variables are consumed here.
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public extension String {

    /// `true` when the string is empty or contains only whitespace/newlines.
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// The string with leading and trailing whitespace and newlines removed.
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    /// `true` when the string matches a standard email-address pattern.
    var isValidEmail: Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return range(of: regex, options: .regularExpression) != nil
    }

    /// `true` when the string can be parsed as a `URL` by `Foundation`.
    var isValidURL: Bool { URL(string: self) != nil }

    /// `true` when every character in the (non-empty) string is a decimal digit.
    var isNumeric: Bool { !isEmpty && allSatisfy(\.isNumber) }

    /// The string parsed as an `Int`, or `nil` if conversion fails.
    var toInt: Int? { Int(self) }

    /// The string parsed as a `Double`, or `nil` if conversion fails.
    var toDouble: Double? { Double(self) }

    /// The string interpreted as a boolean (`"true"`, `"yes"`, `"1"` → `true`;
    /// `"false"`, `"no"`, `"0"` → `false`; anything else → `nil`).
    var toBool: Bool? {
        switch lowercased() {
        case "true", "yes", "1": return true
        case "false", "no", "0": return false
        default: return nil
        }
    }

    /// Truncate the string to `length` characters, appending `trailing` when truncated.
    ///
    /// - Parameters:
    ///   - length: Maximum number of characters before the trailing token.
    ///   - trailing: Token appended when truncation occurs; defaults to `"..."`.
    /// - Returns: The original string when `count <= length`, otherwise the truncated form.
    func truncated(to length: Int, trailing: String = "...") -> String {
        count > length ? String(prefix(length)) + trailing : self
    }

    /// Split the string on whitespace and newlines, discarding empty components.
    ///
    /// - Returns: An array of non-empty word strings in their original order.
    func words() -> [String] {
        components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    /// Convert the string to lowerCamelCase by splitting on non-alphanumeric separators.
    ///
    /// - Returns: A camelCase string (e.g. `"hello-world"` → `"helloWorld"`).
    func camelCased() -> String {
        let parts = components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        guard let first = parts.first else { return self }
        return first.lowercased() + parts.dropFirst().map(\.localizedCapitalized).joined()
    }

    /// Convert a camelCase or mixed-case string to snake_case.
    ///
    /// - Returns: A lowercase snake_case string (e.g. `"myVariableName"` → `"my_variable_name"`).
    func snakeCased() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(startIndex..., in: self)
        let result = regex?.stringByReplacingMatches(in: self, range: range, withTemplate: "$1_$2") ?? self
        return result.lowercased()
    }

    /// The Base64-encoded representation of the string's UTF-8 bytes, or `nil` if encoding fails.
    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    /// Decode the string as a Base64 payload and return the UTF-8 text, or `nil` on failure.
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Check whether the string contains a substring, with optional case-insensitivity.
    ///
    /// - Parameters:
    ///   - string: The substring to search for.
    ///   - caseInsensitive: When `true`, the search ignores letter case.
    /// - Returns: `true` when `string` is found.
    func contains(_ string: String, caseInsensitive: Bool) -> Bool {
        caseInsensitive
            ? range(of: string, options: .caseInsensitive) != nil
            : contains(string)
    }

    /// Access the character at an integer index without risking an out-of-bounds crash.
    ///
    /// - Parameter index: Zero-based character position.
    /// - Returns: The character at `index`, or `nil` when out of range.
    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// Slice the string using integer bounds, clamped to the valid range.
    ///
    /// - Parameter range: Zero-based half-open range of character positions.
    /// - Returns: The substring within the given range.
    subscript(range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(startIndex, offsetBy: min(count, range.upperBound))
        return String(self[start..<end])
    }
}
