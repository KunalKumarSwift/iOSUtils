import Foundation

public enum ValidationResult {
    case valid
    case invalid(String)

    public var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    public var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}

public struct Validator {

    public static func email(_ value: String) -> ValidationResult {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return value.range(of: regex, options: .regularExpression) != nil
            ? .valid
            : .invalid("Enter a valid email address.")
    }

    public static func phone(_ value: String, allowedFormats: [String] = []) -> ValidationResult {
        let digits = value.filter(\.isNumber)
        guard (10...15).contains(digits.count) else {
            return .invalid("Enter a valid phone number.")
        }
        return .valid
    }

    public static func password(
        _ value: String,
        minLength: Int = 8,
        requireUppercase: Bool = true,
        requireDigit: Bool = true,
        requireSpecial: Bool = false
    ) -> ValidationResult {
        guard value.count >= minLength else {
            return .invalid("Password must be at least \(minLength) characters.")
        }
        if requireUppercase, !value.contains(where: \.isUppercase) {
            return .invalid("Password must contain at least one uppercase letter.")
        }
        if requireDigit, !value.contains(where: \.isNumber) {
            return .invalid("Password must contain at least one digit.")
        }
        if requireSpecial {
            let special = CharacterSet.alphanumerics.union(.whitespaces).inverted
            guard value.unicodeScalars.contains(where: { special.contains($0) }) else {
                return .invalid("Password must contain at least one special character.")
            }
        }
        return .valid
    }

    public static func notEmpty(_ value: String, fieldName: String = "This field") -> ValidationResult {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .invalid("\(fieldName) cannot be empty.")
            : .valid
    }

    public static func minLength(_ value: String, min: Int) -> ValidationResult {
        value.count >= min ? .valid : .invalid("Must be at least \(min) characters.")
    }

    public static func maxLength(_ value: String, max: Int) -> ValidationResult {
        value.count <= max ? .valid : .invalid("Must be \(max) characters or fewer.")
    }

    public static func url(_ value: String) -> ValidationResult {
        guard let url = URL(string: value), url.scheme != nil, url.host != nil else {
            return .invalid("Enter a valid URL.")
        }
        return .valid
    }

    public static func creditCard(_ value: String) -> ValidationResult {
        let digits = value.filter(\.isNumber)
        guard (13...19).contains(digits.count) else { return .invalid("Enter a valid card number.") }
        // Luhn algorithm
        let sum = digits.reversed().enumerated().reduce(0) { total, pair in
            var digit = Int(String(pair.element))!
            if pair.offset % 2 == 1 {
                digit *= 2
                if digit > 9 { digit -= 9 }
            }
            return total + digit
        }
        return sum % 10 == 0 ? .valid : .invalid("Enter a valid card number.")
    }

    public static func combine(_ results: ValidationResult...) -> ValidationResult {
        for result in results {
            if case .invalid = result { return result }
        }
        return .valid
    }
}
