import Foundation

/// How the map camera should point.
nonisolated enum MapCameraRule {
    /// Metres of map across the panel: enough to see the next junction, not the next town.
    static let distance: Double = 700

    /// Camera heading in degrees: the GPS course when rotation is on and known, otherwise north up.
    static func heading(course: Double?, rotates: Bool) -> Double {
        rotates ? (course ?? 0) : 0
    }
}
