/// Value-level helpers added to `Array` and `Collection` for common iOS tasks.
///
/// All helpers are pure and free of side effects.
/// No environment variables are consumed here.
import Foundation

public extension Array {

    /// Access an element by index without risking an out-of-bounds crash.
    ///
    /// - Parameter index: Zero-based position in the array.
    /// - Returns: The element at `index`, or `nil` when out of range.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Split the array into consecutive sub-arrays of at most `size` elements.
    ///
    /// - Parameter size: Maximum number of elements per chunk. Must be > 0; returns `[]` otherwise.
    /// - Returns: An array of sub-arrays preserving the original order.
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

    /// Return the array with duplicates removed, using a key path to determine identity.
    ///
    /// The first occurrence of each key is kept; subsequent duplicates are discarded.
    ///
    /// - Parameter keyPath: Property used to determine uniqueness.
    /// - Returns: An order-preserving array with at most one element per unique key value.
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

public extension Array where Element: Hashable {

    /// Return the array with duplicate elements removed, preserving the first occurrence.
    ///
    /// - Returns: An order-preserving array of unique elements.
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }

    /// Count the occurrences of each distinct element.
    ///
    /// - Returns: A dictionary mapping each element to the number of times it appears.
    func frequency() -> [Element: Int] {
        reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }
}

public extension Array where Element: Equatable {

    /// Return a new array with all occurrences of `element` removed.
    ///
    /// - Parameter element: The value to exclude.
    /// - Returns: A copy of the array without any equal elements.
    func removing(_ element: Element) -> [Element] {
        filter { $0 != element }
    }

    /// Remove all occurrences of `element` from the array in place.
    ///
    /// - Parameter element: The value to remove.
    mutating func remove(_ element: Element) {
        removeAll { $0 == element }
    }
}

public extension Collection {

    /// `true` when the collection contains at least one element.
    var isNotEmpty: Bool { !isEmpty }
}
