import Testing
@testable import EliteSpeed

struct LandscapeLayoutTests {

    @Test func columnWidthFitsTheWiderOfAButtonOrTheClock() {
        // Stacked buttons: the clock text is the wider item.
        #expect(LandscapeLayout.columnWidth(buttonSize: 64, clockWidth: 104, padding: 12) == 128)
        #expect(LandscapeLayout.columnWidth(buttonSize: 64, clockWidth: 40, padding: 12) == 88)
    }

    @Test func bareDigitsSplitTheRemainder35To40() {
        let w = LandscapeLayout.widths(total: 780, column: 240, speedNatural: nil, showColumn: true, showMap: true)
        #expect(w.column == 240 && w.speed == 252 && w.map == 288)
    }

    @Test func roundelTakesItsNaturalWidthAndTheMapGetsTheRest() {
        let w = LandscapeLayout.widths(total: 660, column: 96, speedNatural: 410, showColumn: true, showMap: true)
        #expect(w.speed == 410 && w.map == 154)
    }

    @Test func mapKeepsAMinimumWidthAgainstAWideRoundel() {
        let w = LandscapeLayout.widths(total: 660, column: 96, speedNatural: 500, showColumn: true, showMap: true)
        #expect(w.map == LandscapeLayout.minimumMapWidth && w.speed == 564 - LandscapeLayout.minimumMapWidth)
    }

    @Test func hiddenMapGivesAllRemainingWidthToTheSpeed() {
        let w = LandscapeLayout.widths(total: 780, column: 240, speedNatural: 410, showColumn: true, showMap: false)
        #expect(w.speed == 540 && w.map == 0)
    }

    @Test func hiddenColumnGivesItsWidthToSpeedAndMap() {
        let w = LandscapeLayout.widths(total: 780, column: 240, speedNatural: nil, showColumn: false, showMap: true)
        #expect(w.column == 0 && w.speed == 364 && w.map == 416)
    }
}
