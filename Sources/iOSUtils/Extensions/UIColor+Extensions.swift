/// Value-level helpers added to `UIColor` for hex parsing, manipulation, and generation.
///
/// All methods are pure and produce new `UIColor` instances without mutation.
/// No environment variables are consumed here.
#if canImport(UIKit)
import UIKit

public extension UIColor {

    /// Create a colour from a CSS-style hex string.
    ///
    /// Accepts 6-digit (`RRGGBB`) and 8-digit (`RRGGBBAA`) hex strings, with or
    /// without a leading `#`. Invalid strings fall back to opaque white.
    ///
    /// - Parameters:
    ///   - hex: A hex colour string such as `"#FF3B30"` or `"FF3B30"`.
    ///   - alpha: Opacity value in `[0, 1]`; defaults to fully opaque.
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") { hexSanitized.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b: CGFloat
        switch hexSanitized.count {
        case 6:
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            b = CGFloat(rgb & 0x0000FF) / 255
        case 8:
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// A CSS-style uppercase hex string (e.g. `"#FF3B30"`) representing the colour's RGB components.
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    /// A lighter version of the colour, with brightness increased by `amount`.
    ///
    /// - Parameter amount: Brightness delta in `[0, 1]`; defaults to `0.2`.
    /// - Returns: A new `UIColor` with higher brightness, clamped to `1.0`.
    func lighter(by amount: CGFloat = 0.2) -> UIColor { adjusted(by: abs(amount)) }

    /// A darker version of the colour, with brightness decreased by `amount`.
    ///
    /// - Parameter amount: Brightness delta in `[0, 1]`; defaults to `0.2`.
    /// - Returns: A new `UIColor` with lower brightness, clamped to `0.0`.
    func darker(by amount: CGFloat = 0.2) -> UIColor { adjusted(by: -abs(amount)) }

    private func adjusted(by amount: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: max(0, min(1, b + amount)), alpha: a)
    }

    /// The colour directly opposite on the colour wheel (hue shifted by 180°).
    var complementary: UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: (h + 0.5).truncatingRemainder(dividingBy: 1), saturation: s, brightness: b, alpha: a)
    }

    /// A random opaque colour with independently randomised RGB channels.
    ///
    /// - Parameter alpha: Opacity value in `[0, 1]`; defaults to fully opaque.
    /// - Returns: A new `UIColor` with random red, green, and blue components.
    static func random(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: alpha)
    }
}
#endif
