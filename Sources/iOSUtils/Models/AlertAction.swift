/// Value type representing a single button in an alert or action sheet.
///
/// Plain data struct consumed by `AlertPresenting` providers; no behaviour
/// or UIKit dependency lives here, keeping it importable from any layer.
///
/// Environment variables: none.
#if canImport(UIKit)
import UIKit

/// A button rendered inside an alert or action sheet.
public struct AlertAction {

    /// Label text shown on the button.
    public let title: String

    /// Visual style controlling button colour and placement.
    public let style: UIAlertAction.Style

    /// Closure invoked when the user taps the button; `nil` is a no-op.
    public let handler: (() -> Void)?

    /// Initialise an alert action.
    ///
    /// - Parameters:
    ///   - title: Button label text.
    ///   - style: UIKit action style; defaults to `.default`.
    ///   - handler: Optional tap callback.
    public init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    /// Convenience factory for a cancel-style action.
    ///
    /// - Parameters:
    ///   - title: Button label; defaults to "Cancel".
    ///   - handler: Optional tap callback.
    /// - Returns: A cancel-styled `AlertAction`.
    public static func cancel(_ title: String = "Cancel", handler: (() -> Void)? = nil) -> AlertAction {
        AlertAction(title: title, style: .cancel, handler: handler)
    }

    /// Convenience factory for a destructive-style action.
    ///
    /// - Parameters:
    ///   - title: Button label.
    ///   - handler: Optional tap callback.
    /// - Returns: A destructive-styled `AlertAction`.
    public static func destructive(_ title: String, handler: (() -> Void)? = nil) -> AlertAction {
        AlertAction(title: title, style: .destructive, handler: handler)
    }
}
#endif
