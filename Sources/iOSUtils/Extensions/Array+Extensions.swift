/// Value-level helpers added to `Array` and `Collection` for common iOS tasks.
///
/// All helpers are pure and free of side effects.
/// No environment variables are consumed here.
import Foundation

public extension Array {

    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

public extension Array where Element: Hashable {

    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }

    func frequency() -> [Element: Int] {
        reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }
}

public extension Array where Element: Equatable {

    func removing(_ element: Element) -> [Element] {
        filter { $0 != element }
    }

    mutating func remove(_ element: Element) {
        removeAll { $0 == element }
    }
}

public extension Collection {

    var isNotEmpty: Bool { !isEmpty }
}
