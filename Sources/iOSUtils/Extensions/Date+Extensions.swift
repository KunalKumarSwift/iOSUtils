/// Value-level helpers added to `Date` for common iOS date/time tasks.
///
/// Uses `Calendar.current` throughout; all operations are pure and locale-aware.
/// No environment variables are consumed here.
import Foundation

public extension Date {

    /// `true` when the date falls within the current calendar day.
    var isToday: Bool { Calendar.current.isDateInToday(self) }

    /// `true` when the date falls within the previous calendar day.
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }

    /// `true` when the date falls within the next calendar day.
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }

    /// `true` when the date is strictly after the current moment.
    var isInFuture: Bool { self > Date() }

    /// `true` when the date is strictly before the current moment.
    var isInPast: Bool { self < Date() }

    /// Midnight (00:00:00) at the start of the date's calendar day.
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    /// The last second (23:59:59) of the date's calendar day.
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Midnight on the first day of the date's calendar month.
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// The last second of the last day of the date's calendar month.
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }

    /// The age in whole years from this date to today, suitable for birthdate calculations.
    var age: Int {
        Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }

    /// Return a new date by adding a calendar component value to the receiver.
    ///
    /// - Parameters:
    ///   - component: The calendar unit to add (e.g. `.day`, `.month`, `.year`).
    ///   - value: Number of units to add; negative values subtract.
    /// - Returns: The adjusted date, or the receiver if the calendar calculation fails.
    func adding(_ component: Calendar.Component, value: Int) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }

    /// Format the date using a custom `DateFormatter` format string.
    ///
    /// - Parameters:
    ///   - format: A `DateFormatter`-compatible format string (e.g. `"yyyy-MM-dd"`).
    ///   - locale: The locale applied to the formatter; defaults to `.current`.
    /// - Returns: The formatted date string.
    func formatted(_ format: String, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }

    /// Return a human-readable relative string such as "2 hours ago" or "in 3 days".
    ///
    /// Uses `RelativeDateTimeFormatter` on Apple platforms. On Linux, falls back to
    /// an absolute `"yyyy-MM-dd HH:mm"` format because `RelativeDateTimeFormatter`
    /// is unavailable there.
    func relativeFormatted() -> String {
        // RelativeDateTimeFormatter is unavailable on Linux; fall back to a readable absolute format.
        #if canImport(Darwin)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
        #else
        return formatted("yyyy-MM-dd HH:mm")
        #endif
    }

    /// The absolute number of calendar days between the receiver and another date.
    ///
    /// Both dates are normalised to midnight before the comparison, so
    /// e.g. two dates on the same calendar day return `0`.
    ///
    /// - Parameter date: The date to compare against.
    /// - Returns: A non-negative day count.
    func daysBetween(_ date: Date) -> Int {
        abs(Calendar.current.dateComponents([.day], from: startOfDay, to: date.startOfDay).day ?? 0)
    }

    /// Parse a date from a string using the given format pattern.
    ///
    /// - Parameters:
    ///   - string: The string to parse.
    ///   - format: A `DateFormatter`-compatible format string matching `string`.
    /// - Returns: A `Date` on success, or `nil` when parsing fails.
    static func from(string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}
