import Foundation

/// One GPS speed sample reduced to what the display needs.
struct SpeedReading: Equatable {
    /// Below this the car is parked and GPS is jittering; show 0 rather than 1 or 2.
    static let stationaryFloorKmh = 2.0
    /// Core Location's speedAccuracy (m/s) above which the readout dims.
    static let poorAccuracyThreshold = 3.0

    /// Speed in km/h, or nil when Core Location reported no valid speed.
    let kmh: Double?
    /// Core Location's speedAccuracy in m/s. Negative means unknown.
    let accuracy: Double

    init(metersPerSecond: Double, accuracy: Double) {
        if metersPerSecond < 0 {
            kmh = nil
        } else {
            let raw = metersPerSecond * 3.6
            kmh = raw < Self.stationaryFloorKmh ? 0 : raw
        }
        self.accuracy = accuracy
    }

    var isAccuracyPoor: Bool {
        accuracy < 0 || accuracy > Self.poorAccuracyThreshold
    }

    /// Whole-number speed in the given unit, or nil when there is no reading.
    func displayValue(in unit: SpeedUnit) -> Int? {
        guard let kmh else { return nil }
        switch unit {
        case .kmh: return Int(kmh.rounded())
        case .mph: return Int((kmh / 1.609344).rounded())
        }
    }
}
