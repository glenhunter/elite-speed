import CoreLocation
import Observation

/// Core Location wrapper. Publishes the latest speed sample and the GPS course.
@Observable
final class SpeedModel: NSObject, CLLocationManagerDelegate {
    /// Latest sample, nil until the first location arrives.
    private(set) var reading: SpeedReading?
    /// GPS course from the latest fix, nil when invalid or inaccurate.
    private(set) var course: Double?
    /// Direction of travel, held from the last fix where we were moving. Nil until the first movement.
    private(set) var heading: Double?
    private(set) var authorization: CLAuthorizationStatus = .notDetermined

    /// False when `heading` is held from earlier rather than the current fix.
    var isHeadingLive: Bool {
        Heading.isCourseLive(kmh: reading?.kmh, course: course)
    }

    @ObservationIgnored private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        switch authorization {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
            reading = nil
            course = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        reading = SpeedReading(metersPerSecond: location.speed, accuracy: location.speedAccuracy)
        course = Heading.validCourse(location.course, accuracy: location.courseAccuracy)
        heading = Heading.heldCourse(previous: heading, kmh: reading?.kmh, course: course)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Transient GPS loss is expected in tunnels and under trees; the speed shows "--" and the
        // compass holds its last course, dimmed, until updates resume.
        reading = nil
        course = nil
    }
}
