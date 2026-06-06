/// Defines the contract for alert presentation providers.
///
/// Single-concern interface used by AlertFacade to select the active
/// presenter via the IOSUTILS_ALERT_PROVIDER env var.
/// Separating the protocol from UIKit allows non-UIKit test doubles.
///
/// Environment variables: none (consumed by AlertFacade).
#if canImport(UIKit)
import UIKit

/// Contract every alert presentation provider must satisfy.
public protocol AlertPresenting {

    /// Present a fully configured alert on the given view controller.
    ///
    /// - Parameters:
    ///   - title: Optional alert title.
    ///   - message: Optional descriptive message.
    ///   - actions: Ordered list of actions rendered as buttons.
    ///   - viewController: The view controller that hosts the alert.
    ///   - style: Alert or action sheet layout.
    func show(
        title: String?,
        message: String?,
        actions: [AlertAction],
        on viewController: UIViewController,
        style: UIAlertController.Style
    )
}
#endif
