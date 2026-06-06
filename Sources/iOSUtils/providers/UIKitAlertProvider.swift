/// Concrete alert presentation provider backed by `UIAlertController`.
///
/// Translates `AlertAction` values into `UIAlertAction` instances and
/// presents the controller on the supplied view controller.
/// Selected when IOSUTILS_ALERT_PROVIDER=uikit (the default).
///
/// Environment variables:
///   IOSUTILS_ALERT_PROVIDER – set to "uikit" to activate (default).
#if canImport(UIKit)
import UIKit

/// Presents system `UIAlertController` dialogs.
public final class UIKitAlertProvider: AlertPresenting {

    /// Initialise the provider.
    public init() {}

    public func show(
        title: String?,
        message: String?,
        actions: [AlertAction],
        on viewController: UIViewController,
        style: UIAlertController.Style
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: action.title, style: action.style) { _ in action.handler?() }
            )
        }
        viewController.present(alert, animated: true)
    }
}
#endif
