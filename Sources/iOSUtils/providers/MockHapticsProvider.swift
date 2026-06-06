/// Concrete haptics provider that records calls without triggering hardware.
///
/// Records every call so tests can assert haptic interactions.
/// Selected when IOSUTILS_HAPTICS_PROVIDER=mock.
///
/// Environment variables:
///   IOSUTILS_HAPTICS_PROVIDER – set to "mock" to activate.
#if canImport(UIKit)
import UIKit

/// Records haptic calls silently; intended for unit tests and simulators.
public final class MockHapticsProvider: HapticsProviding {

    /// All impact styles requested since initialisation or last `reset()`.
    public private(set) var impactCalls: [UIImpactFeedbackGenerator.FeedbackStyle] = []

    /// All notification types requested since initialisation or last `reset()`.
    public private(set) var notificationCalls: [UINotificationFeedbackGenerator.FeedbackType] = []

    /// Number of selection haptics requested since initialisation or last `reset()`.
    public private(set) var selectionCallCount: Int = 0

    /// Initialise a clean recording provider.
    public init() {}

    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impactCalls.append(style)
    }

    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationCalls.append(type)
    }

    public func selection() {
        selectionCallCount += 1
    }

    /// Clear all recorded calls.
    public func reset() {
        impactCalls.removeAll()
        notificationCalls.removeAll()
        selectionCallCount = 0
    }
}
#endif
