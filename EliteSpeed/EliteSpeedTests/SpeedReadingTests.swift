import Testing
@testable import EliteSpeed

struct SpeedReadingTests {

    @Test func negativeSpeedMeansNoReading() {
        let reading = SpeedReading(metersPerSecond: -1, accuracy: 1)
        #expect(reading.kmh == nil)
    }

    @Test func convertsMetersPerSecondToKmh() {
        let reading = SpeedReading(metersPerSecond: 20, accuracy: 1)
        #expect(reading.kmh == 72)
    }

    @Test func clampsGpsJitterToZeroWhenStationary() {
        // 0.4 m/s is 1.44 km/h: typical parked-car jitter, below the 2 km/h floor.
        let reading = SpeedReading(metersPerSecond: 0.4, accuracy: 1)
        #expect(reading.kmh == 0)
    }

    @Test func accuracyAboveThreeMetersPerSecondIsPoor() {
        let reading = SpeedReading(metersPerSecond: 20, accuracy: 3.5)
        #expect(reading.isAccuracyPoor)
    }

    @Test func accuracyWithinThreeMetersPerSecondIsFine() {
        let reading = SpeedReading(metersPerSecond: 20, accuracy: 1)
        #expect(!reading.isAccuracyPoor)
    }

    @Test func negativeAccuracyMeansUnknownAndIsPoor() {
        let reading = SpeedReading(metersPerSecond: 20, accuracy: -1)
        #expect(reading.isAccuracyPoor)
    }

    @Test func displayValueInKmhIsRounded() {
        let reading = SpeedReading(metersPerSecond: 13.75, accuracy: 1) // 49.5 km/h
        #expect(reading.displayValue(in: .kmh) == 50)
    }

    @Test func displayValueInMphConverts() {
        let reading = SpeedReading(metersPerSecond: 27.7778, accuracy: 1) // 100 km/h
        #expect(reading.displayValue(in: .mph) == 62)
    }

    @Test func displayValueIsNilWithoutReading() {
        let reading = SpeedReading(metersPerSecond: -1, accuracy: 1)
        #expect(reading.displayValue(in: .kmh) == nil)
    }
}
