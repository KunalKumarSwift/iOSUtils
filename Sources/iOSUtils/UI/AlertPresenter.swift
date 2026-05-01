#if canImport(UIKit)
import UIKit

public struct AlertAction {
    public let title: String
    public let style: UIAlertAction.Style
    public let handler: (() -> Void)?

    public init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    public static func cancel(_ title: String = "Cancel", handler: (() -> Void)? = nil) -> AlertAction {
        AlertAction(title: title, style: .cancel, handler: handler)
    }

    public static func destructive(_ title: String, handler: (() -> Void)? = nil) -> AlertAction {
        AlertAction(title: title, style: .destructive, handler: handler)
    }
}

public final class AlertPresenter {

    public static func show(
        title: String?,
        message: String?,
        actions: [AlertAction],
        on viewController: UIViewController,
        style: UIAlertController.Style = .alert
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { action in
            alert.addAction(UIAlertAction(title: action.title, style: action.style) { _ in action.handler?() })
        }
        viewController.present(alert, animated: true)
    }

    public static func showOK(
        title: String?,
        message: String?,
        on viewController: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        show(
            title: title,
            message: message,
            actions: [AlertAction(title: "OK", handler: completion)],
            on: viewController
        )
    }

    public static func showConfirmation(
        title: String?,
        message: String?,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        on viewController: UIViewController,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        show(
            title: title,
            message: message,
            actions: [
                AlertAction(title: confirmTitle, handler: onConfirm),
                .cancel(cancelTitle, handler: onCancel)
            ],
            on: viewController
        )
    }

    public static func showDestructive(
        title: String?,
        message: String?,
        destructiveTitle: String,
        on viewController: UIViewController,
        onDestruct: @escaping () -> Void
    ) {
        show(
            title: title,
            message: message,
            actions: [
                .destructive(destructiveTitle, handler: onDestruct),
                .cancel()
            ],
            on: viewController
        )
    }

    public static func showTextInput(
        title: String?,
        message: String?,
        placeholder: String? = nil,
        on viewController: UIViewController,
        onSubmit: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = placeholder }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            onSubmit(alert.textFields?.first?.text ?? "")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        viewController.present(alert, animated: true)
    }
}
#endif
