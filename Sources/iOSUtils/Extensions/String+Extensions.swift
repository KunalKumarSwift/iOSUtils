/// Value-level helpers added to `String` for common iOS tasks.
///
/// All helpers are pure functions or computed properties with no side effects.
/// No environment variables are consumed here.
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public extension String {

    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    var isValidEmail: Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return range(of: regex, options: .regularExpression) != nil
    }

    var isValidURL: Bool { URL(string: self) != nil }

    var isNumeric: Bool { !isEmpty && allSatisfy(\.isNumber) }

    var toInt: Int? { Int(self) }

    var toDouble: Double? { Double(self) }

    var toBool: Bool? {
        switch lowercased() {
        case "true", "yes", "1": return true
        case "false", "no", "0": return false
        default: return nil
        }
    }

    func truncated(to length: Int, trailing: String = "...") -> String {
        count > length ? String(prefix(length)) + trailing : self
    }

    func words() -> [String] {
        components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    func camelCased() -> String {
        let parts = components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        guard let first = parts.first else { return self }
        return first.lowercased() + parts.dropFirst().map(\.localizedCapitalized).joined()
    }

    func snakeCased() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(startIndex..., in: self)
        let result = regex?.stringByReplacingMatches(in: self, range: range, withTemplate: "$1_$2") ?? self
        return result.lowercased()
    }

    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func contains(_ string: String, caseInsensitive: Bool) -> Bool {
        caseInsensitive
            ? range(of: string, options: .caseInsensitive) != nil
            : contains(string)
    }

    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    subscript(range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(startIndex, offsetBy: min(count, range.upperBound))
        return String(self[start..<end])
    }
}
