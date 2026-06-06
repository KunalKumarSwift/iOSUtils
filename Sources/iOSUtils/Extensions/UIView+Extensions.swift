/// Convenience helpers added to `UIView` for layout, styling, and animation.
///
/// All methods produce side-effects only on the receiver view.
/// No environment variables are consumed here.
#if canImport(UIKit)
import UIKit

public extension UIView {

    /// Add multiple subviews in a single call.
    ///
    /// - Parameter views: One or more views to add, in the order provided.
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }

    /// Pin all four edges of the receiver to a view using Auto Layout.
    ///
    /// Sets `translatesAutoresizingMaskIntoConstraints = false` on the receiver.
    ///
    /// - Parameters:
    ///   - view: The view to pin to.
    ///   - insets: Edge insets applied to each side; defaults to `.zero`.
    func pinToEdges(of view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Centre the receiver within a view using Auto Layout.
    ///
    /// Sets `translatesAutoresizingMaskIntoConstraints = false` on the receiver.
    ///
    /// - Parameter view: The view to centre within.
    func center(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    /// Apply a uniform corner radius and clip the view to its bounds.
    ///
    /// - Parameter radius: Corner radius in points.
    func roundCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    /// Apply a shadow to the view's layer.
    ///
    /// - Parameters:
    ///   - color: Shadow colour; defaults to `.black`.
    ///   - opacity: Shadow opacity in `[0, 1]`; defaults to `0.2`.
    ///   - offset: Shadow offset; defaults to `(0, 2)`.
    ///   - radius: Shadow blur radius in points; defaults to `4`.
    func addShadow(color: UIColor = .black, opacity: Float = 0.2, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }

    /// Apply a solid border to the view's layer.
    ///
    /// - Parameters:
    ///   - color: Border colour.
    ///   - width: Border width in points; defaults to `1`.
    func addBorder(color: UIColor, width: CGFloat = 1) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    /// Play a horizontal shake animation on the view, commonly used to signal invalid input.
    ///
    /// - Parameters:
    ///   - duration: Total animation duration in seconds; defaults to `0.5`.
    ///   - intensity: Maximum horizontal displacement in points; defaults to `10`.
    func shake(duration: TimeInterval = 0.5, intensity: CGFloat = 10) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [-intensity, intensity, -intensity * 0.8, intensity * 0.8, -intensity * 0.5, intensity * 0.5, 0]
        layer.add(animation, forKey: "shake")
    }

    /// Fade the view in from fully transparent.
    ///
    /// Sets `isHidden = false` and animates `alpha` from `0` to `1`.
    ///
    /// - Parameters:
    ///   - duration: Animation duration in seconds; defaults to `0.3`.
    ///   - completion: Optional closure called after the animation finishes.
    func fadeIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration, animations: { self.alpha = 1 }) { _ in completion?() }
    }

    /// Fade the view out to fully transparent, then hide it.
    ///
    /// Animates `alpha` from its current value to `0`, then sets `isHidden = true`.
    ///
    /// - Parameters:
    ///   - duration: Animation duration in seconds; defaults to `0.3`.
    ///   - completion: Optional closure called after the animation finishes.
    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: { self.alpha = 0 }) { _ in
            self.isHidden = true
            completion?()
        }
    }

    /// Render the view's current appearance into a `UIImage`.
    ///
    /// - Returns: A bitmap snapshot of the view at its current size.
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    /// Walk the responder chain to find the nearest ancestor `UIViewController`.
    ///
    /// - Returns: The closest view controller in the responder chain, or `nil` if none is found.
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController { return vc }
            responder = next
        }
        return nil
    }
}
#endif
