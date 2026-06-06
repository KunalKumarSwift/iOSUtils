/// Concrete validation provider implementing standard rules.
///
/// Uses regex for email/URL, digit counting for phone and card length,
/// and the Luhn algorithm for credit card integrity.
/// Selected when IOSUTILS_VALIDATOR_PROVIDER=standard (the default).
///
/// Environment variables:
///   IOSUTILS_VALIDATOR_PROVIDER – set to "standard" to activate (default).
import Foundation

/// Validates common input types using standard rules.
public final class StandardValidatorProvider: ValidatorProviding {

    /// Initialise the provider.
    public init() {}

    public func email(_ value: String) -> ValidationResult {
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
            ? .valid
            : .invalid("Enter a valid email address.")
    }

    public func phone(_ value: String) -> ValidationResult {
        let digits = value.filter(\.isNumber)
        return (10...15).contains(digits.count)
            ? .valid
            : .invalid("Enter a valid phone number.")
    }

    public func password(
        _ value: String,
        minLength: Int,
        requireUppercase: Bool,
        requireDigit: Bool,
        requireSpecial: Bool
    ) -> ValidationResult {
        if value.count < minLength {
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

    public func notEmpty(_ value: String, fieldName: String) -> ValidationResult {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .invalid("\(fieldName) cannot be empty.")
            : .valid
    }

    public func url(_ value: String) -> ValidationResult {
        guard let u = URL(string: value), u.scheme != nil, u.host != nil else {
            return .invalid("Enter a valid URL.")
        }
        return .valid
    }

    public func creditCard(_ value: String) -> ValidationResult {
        let digits = value.filter(\.isNumber)
        guard (13...19).contains(digits.count) else { return .invalid("Enter a valid card number.") }
        return _luhn(digits) ? .valid : .invalid("Enter a valid card number.")
    }

    private func _luhn(_ digits: String) -> Bool {
        let sum = digits.reversed().enumerated().reduce(0) { total, pair in
            var d = Int(String(pair.element))!
            if pair.offset % 2 == 1 { d *= 2; if d > 9 { d -= 9 } }
            return total + d
        }
        return sum % 10 == 0
    }
}
