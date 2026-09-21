import Foundation

/// Pure heading rules: when to trust the GPS course and what to call the direction.
nonisolated enum Heading {
    /// Below this GPS course is noise; the magnetometer takes over.
    static let courseSpeedFloorKmh = 7.0
    /// Core Location courseAccuracy (degrees) at or above which the course is ignored.
    static let courseAccuracyLimit = 20.0

    /// GPS course in degrees, or nil when Core Location marks it invalid or too inaccurate.
    /// A negative accuracy is Core Location's "unknown" sentinel, not a perfect fix.
    static func validCourse(_ course: Double, accuracy: Double) -> Double? {
        course >= 0 && accuracy >= 0 && accuracy < courseAccuracyLimit ? course : nil
    }

    /// True when the car is moving fast enough for the GPS course to be trusted.
    static func isCourseLive(kmh: Double?, course: Double?) -> Bool {
        guard let kmh, let _ = course else { return false }
        return kmh > courseSpeedFloorKmh
    }

    /// The course to point at: the live GPS course when moving, otherwise whatever we last held.
    /// A parked car still points where it last drove.
    static func heldCourse(previous: Double?, kmh: Double?, course: Double?) -> Double? {
        isCourseLive(kmh: kmh, course: course) ? course : previous
    }

    private static let points = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]

    /// Nearest of the eight compass points.
    static func cardinal(_ degrees: Double) -> String {
        let index = Int((degrees / 45).rounded()) % points.count
        return points[(index + points.count) % points.count]
    }
}
