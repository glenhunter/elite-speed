import CoreLocation
import Observation

/// Core Location wrapper. Publishes the latest speed sample; heading and course arrive at M5.
@Observable
final class SpeedModel: NSObject, CLLocationManagerDelegate {
    /// Latest sample, nil until the first location arrives.
    private(set) var reading: SpeedReading?
    private(set) var authorization: CLAuthorizationStatus = .notDetermined

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
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        reading = SpeedReading(metersPerSecond: location.speed, accuracy: location.speedAccuracy)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Transient GPS loss is expected in tunnels and under trees; the view shows "--" until updates resume.
        reading = nil
    }
}
