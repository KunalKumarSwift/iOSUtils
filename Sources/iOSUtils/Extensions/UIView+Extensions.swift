/// Convenience helpers added to `UIView` for layout, styling, and animation.
///
/// All methods produce side-effects only on the receiver view.
/// No environment variables are consumed here.
#if canImport(UIKit)
import UIKit

public extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }

    func pinToEdges(of view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func center(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func roundCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func addShadow(color: UIColor = .black, opacity: Float = 0.2, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }

    func addBorder(color: UIColor, width: CGFloat = 1) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    func shake(duration: TimeInterval = 0.5, intensity: CGFloat = 10) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [-intensity, intensity, -intensity * 0.8, intensity * 0.8, -intensity * 0.5, intensity * 0.5, 0]
        layer.add(animation, forKey: "shake")
    }

    func fadeIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration, animations: { self.alpha = 1 }) { _ in completion?() }
    }

    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: { self.alpha = 0 }) { _ in
            self.isHidden = true
            completion?()
        }
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

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
