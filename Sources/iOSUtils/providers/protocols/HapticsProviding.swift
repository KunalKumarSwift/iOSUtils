/// Defines the contract for haptic feedback providers.
///
/// Single-concern interface used by HapticsFacade to select the active
/// provider via the IOSUTILS_HAPTICS_PROVIDER env var.
/// A mock provider enables silent execution in unit tests and simulators.
///
/// Environment variables: none (consumed by HapticsFacade).
#if canImport(UIKit)
import UIKit

/// Contract every haptics provider must satisfy.
public protocol HapticsProviding {

    /// Trigger an impact haptic at the given intensity.
    ///
    /// - Parameter style: UIKit feedback style (light, medium, heavy, soft, rigid).
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)

    /// Trigger a semantic notification haptic.
    ///
    /// - Parameter type: UIKit feedback type (success, warning, error).
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType)

    /// Trigger the selection-changed haptic.
    func selection()
}
#endif
