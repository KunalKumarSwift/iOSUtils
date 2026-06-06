/// Defines the contract for input validation providers.
///
/// Single-concern interface used by ValidatorFacade to select the active
/// validator via the IOSUTILS_VALIDATOR_PROVIDER env var.
/// Custom rule sets can be introduced without touching existing code.
///
/// Environment variables: none (consumed by ValidatorFacade).
import Foundation

/// Contract every validation provider must satisfy.
public protocol ValidatorProviding {

    /// Validate an email address string.
    ///
    /// - Parameter value: Raw input from the user.
    /// - Returns: `.valid` or `.invalid` with a user-facing message.
    func email(_ value: String) -> ValidationResult

    /// Validate a phone number string.
    ///
    /// - Parameter value: Raw input that may contain formatting characters.
    /// - Returns: `.valid` or `.invalid` with a user-facing message.
    func phone(_ value: String) -> ValidationResult

    /// Validate a password against configurable complexity rules.
    ///
    /// - Parameters:
    ///   - value: Plain-text password candidate.
    ///   - minLength: Minimum character count.
    ///   - requireUppercase: Require at least one uppercase letter.
    ///   - requireDigit: Require at least one digit.
    ///   - requireSpecial: Require at least one non-alphanumeric character.
    /// - Returns: `.valid` or `.invalid` with a user-facing message.
    func password(
        _ value: String,
        minLength: Int,
        requireUppercase: Bool,
        requireDigit: Bool,
        requireSpecial: Bool
    ) -> ValidationResult

    /// Validate that a field is not blank.
    ///
    /// - Parameters:
    ///   - value: Input string to check.
    ///   - fieldName: Display name used in the error message.
    /// - Returns: `.valid` or `.invalid` with a user-facing message.
    func notEmpty(_ value: String, fieldName: String) -> ValidationResult

    /// Validate a URL string.
    ///
    /// - Parameter value: Raw URL string.
    /// - Returns: `.valid` or `.invalid` with a user-facing message.
    func url(_ value: String) -> ValidationResult

    /// Validate a credit card number using the Luhn algorithm.
    ///
    /// - Parameter value: Card number string, may include spaces or dashes.
    /// - Returns: `.valid` or `.invalid` with a user-facing message.
    func creditCard(_ value: String) -> ValidationResult
}
