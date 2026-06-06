/// Value type representing the outcome of any validation check.
///
/// Plain data struct with no behaviour — logic lives in validator providers.
/// Separating it from validators lets UI layers depend only on this type.
///
/// Environment variables: none.
import Foundation

/// The result of a single validation check.
public enum ValidationResult {

    /// The input passed all checks.
    case valid

    /// The input failed a check; the associated value is a user-facing message.
    case invalid(String)

    /// Whether the result represents a passing check.
    public var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    /// The user-facing error message, or `nil` when the result is valid.
    public var errorMessage: String? {
        if case .invalid(let msg) = self { return msg }
        return nil
    }
}
