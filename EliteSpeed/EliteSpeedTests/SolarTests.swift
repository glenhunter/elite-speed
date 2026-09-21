import Foundation
import Testing
@testable import EliteSpeed

struct SolarTests {
    static let london = (lat: 51.5074, lon: -0.1278)
    static let sydney = (lat: -33.8688, lon: 151.2093)
    static let svalbard = (lat: 78.2232, lon: 15.6267)

    static func utc(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int) -> Date {
        var c = DateComponents(); c.year = y; c.month = mo; c.day = d; c.hour = h; c.minute = mi
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(identifier: "UTC")!
        return cal.date(from: c)!
    }

    static func minutes(_ a: Date, _ b: Date) -> Double { abs(a.timeIntervalSince(b)) / 60 }

    // Official sunrise and sunset (sun 0.833° below horizon) against published times.

    @Test func londonMidsummerSunriseAndSunset() throws {
        let day = Self.utc(2025, 6, 21, 12, 0)
        let events = try #require(Solar.events(on: day, latitude: Self.london.lat, longitude: Self.london.lon, zenith: .official).normal)
        #expect(Self.minutes(events.rise, Self.utc(2025, 6, 21, 3, 43)) < 5)   // 04:43 BST
        #expect(Self.minutes(events.set, Self.utc(2025, 6, 21, 20, 21)) < 5)   // 21:21 BST
    }

    @Test func sydneyMidwinterSunriseAndSunset() throws {
        let day = Self.utc(2025, 6, 21, 12, 0)
        let events = try #require(Solar.events(on: day, latitude: Self.sydney.lat, longitude: Self.sydney.lon, zenith: .official).normal)
        // Events are for the UTC day: the sunrise inside 21 June UTC is local 22 June, 07:00 AEST.
        #expect(Self.minutes(events.rise, Self.utc(2025, 6, 21, 21, 0)) < 5)
        #expect(Self.minutes(events.set, Self.utc(2025, 6, 21, 6, 54)) < 5)    // 16:54 AEST
    }

    // Night uses civil twilight (sun 6° below horizon).

    @Test func londonNoonIsDay() {
        #expect(!Solar.isNight(at: Self.utc(2025, 6, 21, 12, 0), latitude: Self.london.lat, longitude: Self.london.lon))
    }

    @Test func londonJustAfterSunsetIsStillTwilight() {
        // Sunset 20:21 UTC, civil dusk about 21:07 UTC.
        #expect(!Solar.isNight(at: Self.utc(2025, 6, 21, 20, 40), latitude: Self.london.lat, longitude: Self.london.lon))
    }

    @Test func londonLateEveningIsNight() {
        #expect(Solar.isNight(at: Self.utc(2025, 6, 21, 22, 30), latitude: Self.london.lat, longitude: Self.london.lon))
    }

    @Test func londonMidwinterAfternoonIsNight() {
        // Sunset 15:53 GMT, civil dusk about 16:34 GMT on 21 December.
        #expect(Solar.isNight(at: Self.utc(2025, 12, 21, 17, 0), latitude: Self.london.lat, longitude: Self.london.lon))
    }

    @Test func sydneyDaySpansUtcMidnight() {
        // Local noon is 02:00 UTC; local 22:00 is 12:00 UTC.
        #expect(!Solar.isNight(at: Self.utc(2025, 6, 21, 2, 0), latitude: Self.sydney.lat, longitude: Self.sydney.lon))
        #expect(Solar.isNight(at: Self.utc(2025, 6, 21, 12, 0), latitude: Self.sydney.lat, longitude: Self.sydney.lon))
    }

    @Test func polarSummerIsNeverNight() {
        #expect(!Solar.isNight(at: Self.utc(2025, 6, 21, 0, 30), latitude: Self.svalbard.lat, longitude: Self.svalbard.lon))
    }

    @Test func firstDayOfPolarNightIsNight() {
        // 14 December at 72.8°N: the setting solve is just out of range while the rising one is
        // still inside, so the day must be classified from the failing solve, not the other.
        #expect(Solar.isNight(at: Self.utc(2025, 12, 14, 12, 0), latitude: 72.8, longitude: 0))
    }

    @Test func polarWinterIsAlwaysNight() {
        #expect(Solar.isNight(at: Self.utc(2025, 12, 21, 11, 0), latitude: Self.svalbard.lat, longitude: Self.svalbard.lon))
    }
}
