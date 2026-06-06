/// Value-level helpers added to `Date` for common iOS date/time tasks.
///
/// Uses `Calendar.current` throughout; all operations are pure and locale-aware.
/// No environment variables are consumed here.
import Foundation

public extension Date {

    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }
    var isInFuture: Bool { self > Date() }
    var isInPast: Bool { self < Date() }

    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }

    func adding(_ component: Calendar.Component, value: Int) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }

    func formatted(_ format: String, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }

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

    func daysBetween(_ date: Date) -> Int {
        abs(Calendar.current.dateComponents([.day], from: startOfDay, to: date.startOfDay).day ?? 0)
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }

    static func from(string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}
