import Testing
@testable import EliteSpeed

struct RoundelLayoutTests {
    // Barlow Semi Condensed Medium: cap 0.7em, tabular digit 0.507em.
    static let metrics = RoundelLayout.Metrics(capRatio: 0.7, digitWidthRatio: 0.507, unitInkHeight: 18, gap: 12)

    static func fits(_ size: Double, digits: Int, diameter: Double) -> Bool {
        let width = Double(digits) * Self.metrics.digitWidthRatio * size
        let height = Self.metrics.capRatio * size + Self.metrics.gap + Self.metrics.unitInkHeight
        let radius = diameter / 2
        return (width / 2) * (width / 2) + (height / 2) * (height / 2) <= radius * radius + 0.01
    }

    @Test func twoDigitsFitInsideTheCircle() {
        let size = RoundelLayout.digitSize(diameter: 167, digits: 2, metrics: Self.metrics)
        #expect(Self.fits(size, digits: 2, diameter: 167))
        // And it is not needlessly small: 5% larger would no longer fit.
        #expect(!Self.fits(size * 1.05, digits: 2, diameter: 167))
    }

    @Test func threeDigitsAreSmallerThanTwo() {
        let two = RoundelLayout.digitSize(diameter: 167, digits: 2, metrics: Self.metrics)
        let three = RoundelLayout.digitSize(diameter: 167, digits: 3, metrics: Self.metrics)
        #expect(three < two)
        #expect(Self.fits(three, digits: 3, diameter: 167))
    }

    @Test func biggerCircleGivesBiggerDigits() {
        let small = RoundelLayout.digitSize(diameter: 167, digits: 2, metrics: Self.metrics)
        let large = RoundelLayout.digitSize(diameter: 266, digits: 2, metrics: Self.metrics)
        #expect(large > small)
    }
}
