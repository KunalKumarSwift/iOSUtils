/// Concrete haptics provider backed by UIKit feedback generators.
///
/// Calls the real `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`,
/// and `UISelectionFeedbackGenerator` APIs. Selected when
/// IOSUTILS_HAPTICS_PROVIDER=uikit (the default on device).
///
/// Environment variables:
///   IOSUTILS_HAPTICS_PROVIDER – set to "uikit" to activate (default).
#if canImport(UIKit)
import UIKit

/// Delivers physical haptic feedback via UIKit generators.
public final class UIKitHapticsProvider: HapticsProviding {

    /// Initialise the provider. Generator instances are created per-call to
    /// avoid stale prepared state across long idle periods.
    public init() {}

    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    public func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
#endif
