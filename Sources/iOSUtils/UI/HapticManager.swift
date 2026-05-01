#if canImport(UIKit)
import UIKit

public final class HapticManager {

    public static let shared = HapticManager()
    private init() {}

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

    public func success() { notification(.success) }
    public func warning() { notification(.warning) }
    public func error() { notification(.error) }
    public func light() { impact(.light) }
    public func medium() { impact(.medium) }
    public func heavy() { impact(.heavy) }
}
#endif
