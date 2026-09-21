import Foundation

/// Sunrise, sunset and night, from position and date. Almanac for Computers algorithm,
/// accurate to a minute or two, which is plenty for deciding when headlights go on.
nonisolated enum Solar {
    enum Zenith: Double {
        /// Sun's upper limb on the horizon with refraction: published sunrise and sunset.
        case official = 90.833
        /// Sun 6° below the horizon: civil dawn and dusk.
        case civil = 96
    }

    enum Events: Equatable {
        case normal(rise: Date, set: Date)
        case alwaysLight
        case alwaysDark

        var normal: (rise: Date, set: Date)? {
            if case let .normal(rise, set) = self { return (rise, set) }
            return nil
        }
    }

    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// Rise and set on the UTC calendar day containing `date`.
    static func events(on date: Date, latitude: Double, longitude: Double, zenith: Zenith) -> Events {
        let calendar = utcCalendar
        let dayStart = calendar.startOfDay(for: date)
        let dayOfYear = Double(calendar.ordinality(of: .day, in: .year, for: date) ?? 1)

        guard let rise = eventHour(dayOfYear: dayOfYear, latitude: latitude, longitude: longitude, zenith: zenith.rawValue, rising: true),
              let set = eventHour(dayOfYear: dayOfYear, latitude: latitude, longitude: longitude, zenith: zenith.rawValue, rising: false) else {
            return polarCase(dayOfYear: dayOfYear, latitude: latitude, longitude: longitude, zenith: zenith.rawValue)
        }
        return .normal(rise: dayStart.addingTimeInterval(rise * 3600), set: dayStart.addingTimeInterval(set * 3600))
    }

    /// True between civil dusk and civil dawn.
    static func isNight(at date: Date, latitude: Double, longitude: Double) -> Bool {
        switch events(on: date, latitude: latitude, longitude: longitude, zenith: .civil) {
        case .alwaysLight:
            return false
        case .alwaysDark:
            return true
        case let .normal(dawn, dusk):
            if dawn <= dusk {
                return !(dawn <= date && date < dusk)
            } else {
                // Daylight spans UTC midnight (eastern longitudes): night is the gap between dusk and dawn.
                return dusk <= date && date < dawn
            }
        }
    }

    // MARK: Algorithm

    private static func degrees(_ radians: Double) -> Double { radians * 180 / .pi }
    private static func radians(_ degrees: Double) -> Double { degrees * .pi / 180 }
    private static func sinD(_ d: Double) -> Double { sin(radians(d)) }
    private static func cosD(_ d: Double) -> Double { cos(radians(d)) }
    private static func wrap(_ value: Double, _ range: Double) -> Double {
        let r = value.truncatingRemainder(dividingBy: range)
        return r < 0 ? r + range : r
    }

    /// Hour angle cosine for the sun at the given zenith; outside -1...1 means it never gets there.
    private static func cosHourAngle(dayOfYear: Double, latitude: Double, longitude: Double, zenith: Double, rising: Bool)
        -> (cosH: Double, rightAscensionHours: Double, t: Double) {
        let lngHour = longitude / 15
        let t = dayOfYear + ((rising ? 6 : 18) - lngHour) / 24
        let meanAnomaly = 0.9856 * t - 3.289
        let trueLongitude = wrap(meanAnomaly + 1.916 * sinD(meanAnomaly) + 0.020 * sinD(2 * meanAnomaly) + 282.634, 360)

        var rightAscension = wrap(degrees(atan(0.91764 * tan(radians(trueLongitude)))), 360)
        let lQuadrant = floor(trueLongitude / 90) * 90
        let raQuadrant = floor(rightAscension / 90) * 90
        rightAscension = (rightAscension + (lQuadrant - raQuadrant)) / 15

        let sinDeclination = 0.39782 * sinD(trueLongitude)
        let cosDeclination = cos(asin(sinDeclination))
        let cosH = (cosD(zenith) - sinDeclination * sinD(latitude)) / (cosDeclination * cosD(latitude))
        return (cosH, rightAscension, t)
    }

    /// UTC hour (0..<24) of the event, or nil when the sun never reaches the zenith that day.
    private static func eventHour(dayOfYear: Double, latitude: Double, longitude: Double, zenith: Double, rising: Bool) -> Double? {
        let (cosH, rightAscension, t) = cosHourAngle(dayOfYear: dayOfYear, latitude: latitude, longitude: longitude, zenith: zenith, rising: rising)
        guard (-1...1).contains(cosH) else { return nil }
        let hourAngle = (rising ? 360 - degrees(acos(cosH)) : degrees(acos(cosH))) / 15
        let localMeanTime = hourAngle + rightAscension - 0.06571 * t - 6.622
        return wrap(localMeanTime - longitude / 15, 24)
    }

    /// Classifies a day on which the sun never crosses the zenith. On the boundary day only one of
    /// the two solves is out of range, so the verdict comes from whichever one failed.
    private static func polarCase(dayOfYear: Double, latitude: Double, longitude: Double, zenith: Double) -> Events {
        let rise = cosHourAngle(dayOfYear: dayOfYear, latitude: latitude, longitude: longitude, zenith: zenith, rising: true).cosH
        let set = cosHourAngle(dayOfYear: dayOfYear, latitude: latitude, longitude: longitude, zenith: zenith, rising: false).cosH
        let outOfRange = (-1...1).contains(rise) ? set : rise
        return outOfRange > 1 ? .alwaysDark : .alwaysLight
    }
}
