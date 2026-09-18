import Testing
@testable import EliteSpeed

struct LandscapeLayoutTests {

    @Test func everythingShownUsesTheDesignShares() {
        let s = LandscapeLayout.shares(showColumn: true, showMap: true)
        #expect(s.column == 0.25 && s.speed == 0.35 && s.map == 0.40)
    }

    @Test func hiddenMapGivesItsShareToTheSpeed() {
        let s = LandscapeLayout.shares(showColumn: true, showMap: false)
        #expect(s.column == 0.25 && s.speed == 0.75 && s.map == 0)
    }

    @Test func hiddenColumnGivesItsShareToTheSpeed() {
        let s = LandscapeLayout.shares(showColumn: false, showMap: true)
        #expect(s.column == 0 && s.speed == 0.60 && s.map == 0.40)
    }

    @Test func everythingHiddenLeavesOnlyTheSpeed() {
        let s = LandscapeLayout.shares(showColumn: false, showMap: false)
        #expect(s.speed == 1)
    }
}
