import MapKit
import SwiftUI

/// How the map camera should point.
nonisolated enum MapCameraRule {
    /// Camera height above the car in metres. The ground shown depends on the panel's shape;
    /// 700 shows the next junction, not the next town.
    static let distance: Double = 700

    /// Camera heading in degrees: the GPS course when rotation is on and known, otherwise north up.
    static func heading(course: Double?, rotates: Bool) -> Double {
        rotates ? (course ?? 0) : 0
    }

    /// Movement smaller than GPS jitter: about a metre and a degree.
    static func isSettled(_ a: MapCamera, _ b: MapCamera) -> Bool {
        abs(a.centerCoordinate.latitude - b.centerCoordinate.latitude) < 0.00001
            && abs(a.centerCoordinate.longitude - b.centerCoordinate.longitude) < 0.00001
            && abs(a.heading - b.heading) < 1
    }
}
