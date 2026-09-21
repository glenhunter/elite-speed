import CoreLocation
import Observation

/// Core Location wrapper. Publishes the latest speed sample and the GPS course.
@Observable
final class SpeedModel: NSObject, CLLocationManagerDelegate {
    /// Latest sample, nil until the first location arrives.
    private(set) var reading: SpeedReading?
    /// Direction of travel, held from the last fix where we were moving. Nil until the first movement.
    private(set) var heading: Double?
    /// Latest position, for the map.
    private(set) var coordinate: CLLocationCoordinate2D?
    /// Position rounded to a tenth of a degree, for sunrise and sunset. Changes only every
    /// 10 km or so, so views that read it are not redrawn on every fix.
    private(set) var coarseCoordinate: CLLocationCoordinate2D?
    /// Increments on every accepted fix so views can react even when speed and course are unchanged.
    private(set) var fixCount = 0
    private(set) var authorization: CLAuthorizationStatus = .notDetermined

    /// GPS course from the latest fix, nil when invalid or inaccurate. Only feeds `heading`.
    @ObservationIgnored private var course: Double?

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
        // A dashboard must keep reading through long stops; never let Core Location pause it.
        manager.pausesLocationUpdatesAutomatically = false
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        switch authorization {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
            forgetPosition()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              FixGate.accepts(age: -location.timestamp.timeIntervalSinceNow,
                              horizontalAccuracy: location.horizontalAccuracy) else { return }
        reading = SpeedReading(metersPerSecond: location.speed, accuracy: location.speedAccuracy)
        course = Heading.validCourse(location.course, accuracy: location.courseAccuracy)
        heading = Heading.heldCourse(previous: heading, kmh: reading?.kmh, course: course)
        coordinate = location.coordinate
        let coarse = CLLocationCoordinate2D(latitude: (location.coordinate.latitude * 10).rounded() / 10,
                                            longitude: (location.coordinate.longitude * 10).rounded() / 10)
        if coarseCoordinate?.latitude != coarse.latitude || coarseCoordinate?.longitude != coarse.longitude {
            coarseCoordinate = coarse
        }
        fixCount += 1
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        switch (error as? CLError)?.code {
        case .locationUnknown:
            // Core Location keeps trying; the last reading stands until it succeeds or gives up.
            return
        case .denied:
            forgetPosition()
        default:
            // Transient GPS loss in tunnels and under trees: the speed shows "--" and the compass
            // holds its last course, dimmed, until updates resume.
            reading = nil
            course = nil
        }
    }

    /// Nothing we know about the car's position may outlive its permission or its source.
    private func forgetPosition() {
        reading = nil
        course = nil
        heading = nil
        coordinate = nil
        coarseCoordinate = nil
    }
}
