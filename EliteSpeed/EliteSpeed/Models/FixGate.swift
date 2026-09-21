import Foundation

/// Decides whether a Core Location fix is fresh and precise enough to show.
nonisolated enum FixGate {
    /// Seconds. Core Location's first callback is often a cached fix from a previous session.
    static let maximumAge: TimeInterval = 5
    /// Metres. Beyond this the fix is a cell-tower guess, useless for speed or the map.
    static let maximumHorizontalAccuracy: Double = 200

    static func accepts(age: TimeInterval, horizontalAccuracy: Double) -> Bool {
        age <= maximumAge && horizontalAccuracy >= 0 && horizontalAccuracy <= maximumHorizontalAccuracy
    }
}
